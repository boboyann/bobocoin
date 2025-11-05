;; Bobocoin SIP-010 Fungible Token
(impl-trait .sip-010-ft-trait.sip-010-trait)

;; Error codes
(define-constant ERR-UNAUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-AMOUNT-ZERO u102)
(define-constant ERR-SAME-SENDER-RECIPIENT u103)

;; Owner is the deployer
(define-data-var owner principal tx-sender)

;; Total supply
(define-data-var total-supply uint u0)

;; Balances map
(define-map balances principal uint)

;; --------- Read-only (SIP-010) ---------
(define-read-only (get-name)
  (ok "Bobocoin")
)

(define-read-only (get-symbol)
  (ok "BOBO")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (some (var-get total-supply)))
)

(define-read-only (get-balance (who principal))
  (ok (default-to u0 (map-get? balances who)))
)

;; --------- Public (SIP-010) ---------
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (<= amount u0)
      (err ERR-AMOUNT-ZERO)
      (if (is-eq sender recipient)
          (err ERR-SAME-SENDER-RECIPIENT)
          (if (not (is-eq tx-sender sender))
              (err ERR-UNAUTHORIZED)
              (begin
                (try! (debit sender amount))
                (credit recipient amount)
                (ok true)
              )
          )
      )
  )
)

;; --------- Owner functions ---------
(define-public (mint (amount uint) (recipient principal))
  (if (<= amount u0)
      (err ERR-AMOUNT-ZERO)
      (if (not (is-eq tx-sender (var-get owner)))
          (err ERR-UNAUTHORIZED)
          (begin
            (credit recipient amount)
            (var-set total-supply (+ (var-get total-supply) amount))
            (ok true)
          )
      )
  )
)

(define-public (burn (amount uint) (sender principal))
  (if (<= amount u0)
      (err ERR-AMOUNT-ZERO)
      (if (not (is-eq tx-sender sender))
          (err ERR-UNAUTHORIZED)
          (begin
            (try! (debit sender amount))
            (var-set total-supply (- (var-get total-supply) amount))
            (ok true)
          )
      )
  )
)

;; --------- Internals ---------
(define-private (debit (from principal) (amount uint))
  (let ((current (default-to u0 (map-get? balances from))))
    (if (>= current amount)
        (begin
          (map-set balances from (- current amount))
          (ok true)
        )
        (err ERR-INSUFFICIENT-BALANCE)
    )
  )
)

(define-private (credit (to principal) (amount uint))
  (let ((current (default-to u0 (map-get? balances to))))
    (begin
      (map-set balances to (+ current amount))
      true
    )
  )
)
