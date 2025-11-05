(define-trait sip-010-trait
  (
    ;; Transfers tokens from the sender to a recipient
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; Token metadata
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))

    ;; Supply and balances
    (get-total-supply () (response (optional uint) uint))
    (get-balance (principal) (response uint uint))
  )
)
