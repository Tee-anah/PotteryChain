;; PotteryChain: Ceramic Pottery and Clay Arts Reward System
;; Version: 1.0.0

;; Constants
(define-constant KILN_CAPACITY u1800000)
(define-constant BASE_POTTERY_REWARD u22)
(define-constant CERAMIC_BONUS u8)
(define-constant MAX_POTTER_LEVEL u12)
(define-constant ERR_INVALID_POTTERY_ACTIVITY u1)
(define-constant ERR_NO_POTTERY_TOKENS u2)
(define-constant ERR_KILN_CAPACITY_EXCEEDED u3)
(define-constant BLOCKS_PER_POTTERY_SEASON u1728)
(define-constant CLAY_PRESERVATION_MULTIPLIER u4)
(define-constant MIN_PRESERVATION_PERIOD u864)
(define-constant EARLY_POTTERY_PENALTY u15)

;; Data Variables
(define-data-var total-pottery-tokens-distributed uint u0)
(define-data-var total-pottery-activities uint u0)
(define-data-var kiln-supervisor principal tx-sender)

;; Data Maps
(define-map potter-activities principal uint)
(define-map potter-pottery-tokens principal uint)
(define-map pottery-activity-start-time principal uint)
(define-map potter-ceramic-level principal uint)
(define-map potter-last-activity principal uint)
(define-map potter-preserved-clay principal uint)
(define-map potter-preservation-start-block principal uint)

;; Public Functions
(define-public (start-pottery-activity (firing-duration uint))
  (let
    (
      (potter tx-sender)
    )
    (asserts! (> firing-duration u0) (err ERR_INVALID_POTTERY_ACTIVITY))
    (map-set pottery-activity-start-time potter burn-block-height)
    (ok true)
  ))

(define-public (complete-pottery-piece (firing-duration uint))
  (let
    (
      (potter tx-sender)
      (start-block (default-to u0 (map-get? pottery-activity-start-time potter)))
      (blocks-potting (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? potter-last-activity potter)))
      (ceramic-level (default-to u0 (map-get? potter-ceramic-level potter)))
      (capped-ceramic (if (<= ceramic-level MAX_POTTER_LEVEL) ceramic-level MAX_POTTER_LEVEL))
      (pottery-reward (+ BASE_POTTERY_REWARD (* capped-ceramic CERAMIC_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-potting firing-duration)) (err ERR_INVALID_POTTERY_ACTIVITY))
    
    (map-set potter-activities potter (+ (default-to u0 (map-get? potter-activities potter)) u1))
    (map-set potter-pottery-tokens potter (+ (default-to u0 (map-get? potter-pottery-tokens potter)) pottery-reward))
    
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_POTTERY_SEASON)
      (map-set potter-ceramic-level potter (+ ceramic-level u1))
      (map-set potter-ceramic-level potter u1)
    )
    
    (map-set potter-last-activity potter burn-block-height)
    (var-set total-pottery-activities (+ (var-get total-pottery-activities) u1))
    (var-set total-pottery-tokens-distributed (+ (var-get total-pottery-tokens-distributed) pottery-reward))
    
    (asserts! (<= (var-get total-pottery-tokens-distributed) KILN_CAPACITY) (err ERR_KILN_CAPACITY_EXCEEDED))
    (ok pottery-reward)
  ))

(define-public (claim-pottery-rewards)
  (let
    (
      (potter tx-sender)
      (token-balance (default-to u0 (map-get? potter-pottery-tokens potter)))
    )
    (asserts! (> token-balance u0) (err ERR_NO_POTTERY_TOKENS))
    (map-set potter-pottery-tokens potter u0)
    (ok token-balance)
  ))

;; Clay Preservation Features
(define-public (preserve-clay (amount uint))
  (let
    (
      (potter tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_POTTERY_ACTIVITY))
    (asserts! (>= (var-get total-pottery-tokens-distributed) amount) (err ERR_KILN_CAPACITY_EXCEEDED))
    
    (map-set potter-preserved-clay potter amount)
    (map-set potter-preservation-start-block potter burn-block-height)
    (var-set total-pottery-tokens-distributed (- (var-get total-pottery-tokens-distributed) amount))
    (ok amount)
  ))

(define-public (release-preserved-clay)
  (let
    (
      (potter tx-sender)
      (preserved-amount (default-to u0 (map-get? potter-preserved-clay potter)))
      (preservation-start-block (default-to u0 (map-get? potter-preservation-start-block potter)))
      (blocks-preserved (- burn-block-height preservation-start-block))
      (penalty (if (< blocks-preserved MIN_PRESERVATION_PERIOD) (/ (* preserved-amount EARLY_POTTERY_PENALTY) u100) u0))
      (final-amount (- preserved-amount penalty))
    )
    (asserts! (> preserved-amount u0) (err ERR_NO_POTTERY_TOKENS))
    
    (map-set potter-preserved-clay potter u0)
    (map-set potter-preservation-start-block potter u0)
    (var-set total-pottery-tokens-distributed (+ (var-get total-pottery-tokens-distributed) final-amount))
    (ok final-amount)
  ))

;; Read-Only Functions
(define-read-only (get-pottery-activity-count (user principal))
  (default-to u0 (map-get? potter-activities user)))

(define-read-only (get-pottery-token-balance (user principal))
  (default-to u0 (map-get? potter-pottery-tokens user)))

(define-read-only (get-ceramic-level (user principal))
  (default-to u0 (map-get? potter-ceramic-level user)))

(define-read-only (get-kiln-stats)
  {
    total-pottery-activities: (var-get total-pottery-activities),
    total-pottery-tokens-distributed: (var-get total-pottery-tokens-distributed)
  })

;; Private Functions
(define-private (is-kiln-supervisor)
  (is-eq tx-sender (var-get kiln-supervisor)))