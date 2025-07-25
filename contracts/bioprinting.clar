;; Bioprinting Advancement Contract
;; Develops 3D printing of living tissues and organs

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-PROJECT-NOT-FOUND (err u501))
(define-constant ERR-INVALID-PARAMETERS (err u502))
(define-constant ERR-BIOINK-NOT-FOUND (err u503))
(define-constant ERR-INSUFFICIENT-RESOURCES (err u504))

;; Data Variables
(define-data-var next-project-id uint u1)
(define-data-var next-bioink-id uint u1)

;; Data Maps
(define-map bioprinting-projects
  { project-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    tissue-type: (string-ascii 50),
    target-organ: (string-ascii 50),
    complexity-level: uint,
    print-resolution: uint,
    estimated-duration: uint,
    project-lead: principal,
    institution: (string-ascii 100),
    status: uint,
    funding-required: uint,
    funding-received: uint,
    created-at: uint,
    completion-percentage: uint
  }
)

(define-map bioink-formulations
  { bioink-id: uint }
  {
    name: (string-ascii 100),
    composition: (string-ascii 300),
    cell-types: (list 5 (string-ascii 50)),
    viscosity: uint,
    printability-score: uint,
    biocompatibility-score: uint,
    degradation-rate: uint,
    storage-conditions: (string-ascii 100),
    developed-by: principal,
    validation-status: uint,
    created-at: uint
  }
)

(define-map printing-parameters
  { project-id: uint, parameter-set-id: uint }
  {
    nozzle-diameter: uint,
    print-speed: uint,
    layer-height: uint,
    temperature: uint,
    pressure: uint,
    crosslinking-method: (string-ascii 50),
    post-processing: (string-ascii 200),
    success-rate: uint,
    quality-score: uint,
    optimized-by: principal
  }
)

(define-map tissue-viability-data
  { project-id: uint, test-id: uint }
  {
    cell-viability: uint,
    tissue-function: uint,
    vascularization-score: uint,
    mechanical-properties: uint,
    days-post-printing: uint,
    assessment-method: (string-ascii 100),
    assessed-by: principal,
    assessment-date: uint,
    notes: (string-ascii 300)
  }
)

(define-map clinical-applications
  { project-id: uint, application-id: uint }
  {
    application-type: (string-ascii 100),
    target-condition: (string-ascii 100),
    patient-population: (string-ascii 100),
    regulatory-status: uint,
    clinical-phase: uint,
    safety-profile: uint,
    efficacy-data: uint,
    approval-timeline: uint,
    medical-partner: principal
  }
)

;; Public Functions

;; Create bioprinting project
(define-public (create-bioprinting-project (name (string-ascii 100)) (description (string-ascii 500)) (tissue-type (string-ascii 50)) (target-organ (string-ascii 50)) (complexity-level uint) (print-resolution uint) (estimated-duration uint) (institution (string-ascii 100)) (funding-required uint))
  (let ((project-id (var-get next-project-id)))
    (asserts! (> (len name) u0) ERR-INVALID-PARAMETERS)
    (asserts! (and (>= complexity-level u1) (<= complexity-level u10)) ERR-INVALID-PARAMETERS)
    (asserts! (> print-resolution u0) ERR-INVALID-PARAMETERS)
    (asserts! (> funding-required u0) ERR-INSUFFICIENT-RESOURCES)

    (map-set bioprinting-projects
      { project-id: project-id }
      {
        name: name,
        description: description,
        tissue-type: tissue-type,
        target-organ: target-organ,
        complexity-level: complexity-level,
        print-resolution: print-resolution,
        estimated-duration: estimated-duration,
        project-lead: tx-sender,
        institution: institution,
        status: u1,
        funding-required: funding-required,
        funding-received: u0,
        created-at: block-height,
        completion-percentage: u0
      }
    )

    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

;; Develop bioink formulation
(define-public (develop-bioink (name (string-ascii 100)) (composition (string-ascii 300)) (cell-types (list 5 (string-ascii 50))) (viscosity uint) (storage-conditions (string-ascii 100)))
  (let ((bioink-id (var-get next-bioink-id)))
    (asserts! (> (len name) u0) ERR-INVALID-PARAMETERS)
    (asserts! (> (len composition) u0) ERR-INVALID-PARAMETERS)
    (asserts! (> (len cell-types) u0) ERR-INVALID-PARAMETERS)

    (map-set bioink-formulations
      { bioink-id: bioink-id }
      {
        name: name,
        composition: composition,
        cell-types: cell-types,
        viscosity: viscosity,
        printability-score: u0,
        biocompatibility-score: u0,
        degradation-rate: u0,
        storage-conditions: storage-conditions,
        developed-by: tx-sender,
        validation-status: u1,
        created-at: block-height
      }
    )

    (var-set next-bioink-id (+ bioink-id u1))
    (ok bioink-id)
  )
)

;; Optimize printing parameters
(define-public (optimize-printing-parameters (project-id uint) (parameter-set-id uint) (nozzle-diameter uint) (print-speed uint) (layer-height uint) (temperature uint) (pressure uint) (crosslinking-method (string-ascii 50)) (post-processing (string-ascii 200)))
  (let ((project (unwrap! (map-get? bioprinting-projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND)))
    (asserts! (is-eq (get project-lead project) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> nozzle-diameter u0) ERR-INVALID-PARAMETERS)
    (asserts! (> print-speed u0) ERR-INVALID-PARAMETERS)

    (map-set printing-parameters
      { project-id: project-id, parameter-set-id: parameter-set-id }
      {
        nozzle-diameter: nozzle-diameter,
        print-speed: print-speed,
        layer-height: layer-height,
        temperature: temperature,
        pressure: pressure,
        crosslinking-method: crosslinking-method,
        post-processing: post-processing,
        success-rate: u0,
        quality-score: u0,
        optimized-by: tx-sender
      }
    )
    (ok true)
  )
)

;; Record tissue viability assessment
(define-public (record-tissue-viability (project-id uint) (test-id uint) (cell-viability uint) (tissue-function uint) (vascularization-score uint) (mechanical-properties uint) (days-post-printing uint) (assessment-method (string-ascii 100)) (notes (string-ascii 300)))
  (let ((project (unwrap! (map-get? bioprinting-projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND)))
    (asserts! (and (<= cell-viability u100) (<= tissue-function u100)) ERR-INVALID-PARAMETERS)
    (asserts! (and (<= vascularization-score u100) (<= mechanical-properties u100)) ERR-INVALID-PARAMETERS)

    (map-set tissue-viability-data
      { project-id: project-id, test-id: test-id }
      {
        cell-viability: cell-viability,
        tissue-function: tissue-function,
        vascularization-score: vascularization-score,
        mechanical-properties: mechanical-properties,
        days-post-printing: days-post-printing,
        assessment-method: assessment-method,
        assessed-by: tx-sender,
        assessment-date: block-height,
        notes: notes
      }
    )
    (ok true)
  )
)

;; Register clinical application
(define-public (register-clinical-application (project-id uint) (application-id uint) (application-type (string-ascii 100)) (target-condition (string-ascii 100)) (patient-population (string-ascii 100)) (clinical-phase uint) (medical-partner principal))
  (let ((project (unwrap! (map-get? bioprinting-projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND)))
    (asserts! (is-eq (get project-lead project) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= clinical-phase u1) (<= clinical-phase u4)) ERR-INVALID-PARAMETERS)

    (map-set clinical-applications
      { project-id: project-id, application-id: application-id }
      {
        application-type: application-type,
        target-condition: target-condition,
        patient-population: patient-population,
        regulatory-status: u1,
        clinical-phase: clinical-phase,
        safety-profile: u0,
        efficacy-data: u0,
        approval-timeline: u0,
        medical-partner: medical-partner
      }
    )
    (ok true)
  )
)

;; Update project progress
(define-public (update-project-progress (project-id uint) (completion-percentage uint) (new-status uint))
  (let ((project (unwrap! (map-get? bioprinting-projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND)))
    (asserts! (is-eq (get project-lead project) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= completion-percentage u100) ERR-INVALID-PARAMETERS)
    (asserts! (and (>= new-status u1) (<= new-status u5)) ERR-INVALID-PARAMETERS)

    (map-set bioprinting-projects
      { project-id: project-id }
      (merge project {
        completion-percentage: completion-percentage,
        status: new-status
      })
    )
    (ok true)
  )
)

;; Fund bioprinting project
(define-public (fund-bioprinting-project (project-id uint) (amount uint))
  (let ((project (unwrap! (map-get? bioprinting-projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND)))
    (asserts! (> amount u0) ERR-INSUFFICIENT-RESOURCES)

    (map-set bioprinting-projects
      { project-id: project-id }
      (merge project {
        funding-received: (+ (get funding-received project) amount)
      })
    )
    (ok true)
  )
)

;; Validate bioink formulation
(define-public (validate-bioink (bioink-id uint) (printability-score uint) (biocompatibility-score uint) (degradation-rate uint))
  (let ((bioink (unwrap! (map-get? bioink-formulations { bioink-id: bioink-id }) ERR-BIOINK-NOT-FOUND)))
    (asserts! (is-eq (get developed-by bioink) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (<= printability-score u100) (<= biocompatibility-score u100)) ERR-INVALID-PARAMETERS)

    (map-set bioink-formulations
      { bioink-id: bioink-id }
      (merge bioink {
        printability-score: printability-score,
        biocompatibility-score: biocompatibility-score,
        degradation-rate: degradation-rate,
        validation-status: u2
      })
    )
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-bioprinting-project (project-id uint))
  (map-get? bioprinting-projects { project-id: project-id })
)

(define-read-only (get-bioink-formulation (bioink-id uint))
  (map-get? bioink-formulations { bioink-id: bioink-id })
)

(define-read-only (get-printing-parameters (project-id uint) (parameter-set-id uint))
  (map-get? printing-parameters { project-id: project-id, parameter-set-id: parameter-set-id })
)

(define-read-only (get-tissue-viability-data (project-id uint) (test-id uint))
  (map-get? tissue-viability-data { project-id: project-id, test-id: test-id })
)

(define-read-only (get-clinical-application (project-id uint) (application-id uint))
  (map-get? clinical-applications { project-id: project-id, application-id: application-id })
)

(define-read-only (get-next-project-id)
  (var-get next-project-id)
)

(define-read-only (get-next-bioink-id)
  (var-get next-bioink-id)
)
