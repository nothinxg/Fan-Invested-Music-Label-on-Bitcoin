;; title: Fan-Invested-Music-Label-on-Bitcoin

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-campaign-closed (err u104))
(define-constant err-campaign-active (err u105))
(define-constant err-no-stake (err u106))
(define-constant err-no-revenue (err u107))
(define-constant err-unauthorized (err u108))
(define-constant err-invalid-status (err u109))

(define-data-var next-song-id uint u1)
(define-data-var total-platform-revenue uint u0)

(define-map artists 
  principal 
  {
    name: (string-ascii 50),
    registered-at: uint,
    total-raised: uint,
    song-count: uint
  }
)

(define-map songs 
  uint 
  {
    artist: principal,
    title: (string-ascii 100),
    funding-goal: uint,
    total-staked: uint,
    total-revenue: uint,
    status: (string-ascii 20),
    created-at: uint,
    funded-at: (optional uint)
  }
)

(define-map stakes 
  {staker: principal, song-id: uint}
  {
    amount: uint,
    staked-at: uint,
    claimed-revenue: uint
  }
)

(define-map song-stakers
  uint
  {staker-count: uint}
)

(define-public (register-artist (name (string-ascii 50)))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (is-none (map-get? artists caller)) err-already-exists)
    (ok (map-set artists caller {
      name: name,
      registered-at: stacks-block-height,
      total-raised: u0,
      song-count: u0
    }))
  )
)

(define-public (create-song (title (string-ascii 100)) (funding-goal uint))
  (let
    (
      (caller tx-sender)
      (artist-data (unwrap! (map-get? artists caller) err-not-found))
      (song-id (var-get next-song-id))
    )
    (asserts! (> funding-goal u0) err-invalid-amount)
    (map-set songs song-id {
      artist: caller,
      title: title,
      funding-goal: funding-goal,
      total-staked: u0,
      total-revenue: u0,
      status: "active",
      created-at: stacks-block-height,
      funded-at: none
    })
    (map-set song-stakers song-id {staker-count: u0})
    (map-set artists caller (merge artist-data {song-count: (+ (get song-count artist-data) u1)}))
    (var-set next-song-id (+ song-id u1))
    (ok song-id)
  )
)

(define-public (stake-on-song (song-id uint) (amount uint))
  (let
    (
      (caller tx-sender)
      (song-data (unwrap! (map-get? songs song-id) err-not-found))
      (existing-stake (default-to {amount: u0, staked-at: u0, claimed-revenue: u0} 
        (map-get? stakes {staker: caller, song-id: song-id})))
      (stakers-data (unwrap! (map-get? song-stakers song-id) err-not-found))
    )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq (get status song-data) "active") err-campaign-closed)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    (if (is-eq (get amount existing-stake) u0)
      (map-set song-stakers song-id {staker-count: (+ (get staker-count stakers-data) u1)})
      true
    )
    (map-set stakes {staker: caller, song-id: song-id} {
      amount: (+ (get amount existing-stake) amount),
      staked-at: stacks-block-height,
      claimed-revenue: (get claimed-revenue existing-stake)
    })
    (map-set songs song-id (merge song-data {
      total-staked: (+ (get total-staked song-data) amount)
    }))
    (ok true)
  )
)

(define-public (close-funding (song-id uint))
  (let
    (
      (caller tx-sender)
      (song-data (unwrap! (map-get? songs song-id) err-not-found))
      (artist-data (unwrap! (map-get? artists (get artist song-data)) err-not-found))
    )
    (asserts! (is-eq caller (get artist song-data)) err-unauthorized)
    (asserts! (is-eq (get status song-data) "active") err-invalid-status)
    (asserts! (>= (get total-staked song-data) (get funding-goal song-data)) err-invalid-amount)
    (try! (as-contract (stx-transfer? (get total-staked song-data) tx-sender (get artist song-data))))
    (map-set songs song-id (merge song-data {
      status: "funded",
      funded-at: (some stacks-block-height)
    }))
    (map-set artists (get artist song-data) (merge artist-data {
      total-raised: (+ (get total-raised artist-data) (get total-staked song-data))
    }))
    (ok true)
  )
)

(define-public (add-revenue (song-id uint) (amount uint))
  (let
    (
      (caller tx-sender)
      (song-data (unwrap! (map-get? songs song-id) err-not-found))
    )
    (asserts! (is-eq caller (get artist song-data)) err-unauthorized)
    (asserts! (is-eq (get status song-data) "funded") err-invalid-status)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    (map-set songs song-id (merge song-data {
      total-revenue: (+ (get total-revenue song-data) amount)
    }))
    (var-set total-platform-revenue (+ (var-get total-platform-revenue) amount))
    (ok true)
  )
)

(define-public (claim-rewards (song-id uint))
  (let
    (
      (caller tx-sender)
      (song-data (unwrap! (map-get? songs song-id) err-not-found))
      (stake-data (unwrap! (map-get? stakes {staker: caller, song-id: song-id}) err-no-stake))
      (total-staked (get total-staked song-data))
      (total-revenue (get total-revenue song-data))
      (stake-amount (get amount stake-data))
      (already-claimed (get claimed-revenue stake-data))
      (entitled-revenue (/ (* total-revenue stake-amount) total-staked))
      (claimable-amount (- entitled-revenue already-claimed))
    )
    (asserts! (is-eq (get status song-data) "funded") err-invalid-status)
    (asserts! (> claimable-amount u0) err-no-revenue)
    (try! (as-contract (stx-transfer? claimable-amount tx-sender caller)))
    (map-set stakes {staker: caller, song-id: song-id} (merge stake-data {
      claimed-revenue: entitled-revenue
    }))
    (ok claimable-amount)
  )
)

(define-public (withdraw-stake (song-id uint))
  (let
    (
      (caller tx-sender)
      (song-data (unwrap! (map-get? songs song-id) err-not-found))
      (stake-data (unwrap! (map-get? stakes {staker: caller, song-id: song-id}) err-no-stake))
    )
    (asserts! (is-eq (get status song-data) "active") err-invalid-status)
    (try! (as-contract (stx-transfer? (get amount stake-data) tx-sender caller)))
    (map-delete stakes {staker: caller, song-id: song-id})
    (map-set songs song-id (merge song-data {
      total-staked: (- (get total-staked song-data) (get amount stake-data))
    }))
    (ok (get amount stake-data))
  )
)

(define-read-only (get-artist (artist principal))
  (ok (map-get? artists artist))
)

(define-read-only (get-song (song-id uint))
  (ok (map-get? songs song-id))
)

(define-read-only (get-stake (staker principal) (song-id uint))
  (ok (map-get? stakes {staker: staker, song-id: song-id}))
)

(define-read-only (get-claimable-rewards (staker principal) (song-id uint))
  (let
    (
      (song-data (unwrap! (map-get? songs song-id) err-not-found))
      (stake-data (unwrap! (map-get? stakes {staker: staker, song-id: song-id}) err-no-stake))
      (total-staked (get total-staked song-data))
      (total-revenue (get total-revenue song-data))
      (stake-amount (get amount stake-data))
      (already-claimed (get claimed-revenue stake-data))
      (entitled-revenue (/ (* total-revenue stake-amount) total-staked))
    )
    (ok (- entitled-revenue already-claimed))
  )
)

(define-read-only (get-song-staker-count (song-id uint))
  (ok (map-get? song-stakers song-id))
)

(define-read-only (get-next-song-id)
  (ok (var-get next-song-id))
)

(define-read-only (get-platform-stats)
  (ok {
    total-revenue: (var-get total-platform-revenue),
    total-songs: (- (var-get next-song-id) u1)
  })
)
