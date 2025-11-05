(impl-trait .sip010-trait.sip010-ft-trait)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-FUNDS u101)
(define-constant ERR-ZERO-AMOUNT u102)

;; Token metadata
(define-constant TOKEN-NAME "Peecoin")
(define-constant TOKEN-SYMBOL "PEE")
(define-constant TOKEN-DECIMALS u6)

;; Storage
(define-data-var owner principal tx-sender)
(define-data-var total-supply uint u0)
(define-map balances { owner: principal } { balance: uint })

;; Read-only views (SIP-010)
(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (some (var-get total-supply)))
)

(define-read-only (get-token-uri)
  (ok none)
)

(define-read-only (get-balance (who principal))
  (ok (default-to u0 (get balance (map-get? balances { owner: who }))))
)

;; Internals
(define-private (set-balance (who principal) (amt uint))
  (map-set balances { owner: who } { balance: amt })
)

(define-private (get-balance-internal (who principal))
  (default-to u0 (get balance (map-get? balances { owner: who })))
)

;; SIP-010 transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (let
      (
        (sb (get-balance-internal sender))
        (rb (get-balance-internal recipient))
      )
      (asserts! (>= sb amount) (err ERR-INSUFFICIENT-FUNDS))
      (begin
        (set-balance sender (- sb amount))
        (set-balance recipient (+ rb amount))
        (ok true)
      )
    )
  )
)

;; Owner-only mint
(define-public (mint (recipient principal) (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
    (let ((rb (get-balance-internal recipient)))
      (set-balance recipient (+ rb amount))
      (var-set total-supply (+ (var-get total-supply) amount))
      (ok true)
    )
  )
)

;; Self burn
(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
    (let ((sb (get-balance-internal tx-sender)))
      (asserts! (>= sb amount) (err ERR-INSUFFICIENT-FUNDS))
      (set-balance tx-sender (- sb amount))
      (var-set total-supply (- (var-get total-supply) amount))
      (ok true)
    )
  )
)
