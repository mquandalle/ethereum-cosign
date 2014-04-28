{
  [[0]] 3 ; Number of participants (max 255)
  [[1]] 2 ; Number of required signatures

  [[(- 0x56b7acde001badc18e37e53f390e45be5f90f240)]] 1 ; Participant n°1
  [[(- 0x62e84fb46981e4a7bca6e2cb98cad77e51fc8a36)]] 2 ; Participant n°2
  [[(- 0x6bca5f312d950c6d9aa973c776700e00ae225483)]] 3 ; Participant n°3

  ;; Optional: name registration
  ;[0] "Public name"
  ;(call 0x929b11b8eeea00966e873a241d4b67f7540d1f38 0 0 0 32 0 0)
}

{
  ; Get the caller cosign index
  [myIndex] @@ (- (caller))
  (unless @myIndex (stop))

  ; Action: [1] propose, [2] accept, [3] reject
  [action] (calldataload 0x00)

  ; Propose a new transaction
  (when (= @action 1) {
    [txReceiver] (calldataload 0x20)
    [txAmount] (calldataload 0x40)
    [pendingAmount] @@3

    ; Check if the contract contains enough "none-pending" money
    (when (>= (- (balance (address)) @pendingAmount) @txAmount) {
      ; Calculate the transaction location
      [txId] (+ @@2 1)
      [location] (* @txId 5)

      ; Update the number of transactions
      [[2]] @txId

      ; Add to the pending money
      [[3]] (+ @pendingAmount @txAmount)

      ; Set the state (1: "pending"), the receiver and the amount
      [[@location]] 1
      [[(+ @location 1)]] @txReceiver
      [[(+ @location 2)]] @txAmount

      ; Accept or reject the proposition without doing another contract call
      [action] (calldataload 0x60)
    })
  })

  ; Accept or reject an existing transaction
  (when (|| (= @action 2) (= @action 3)) {
    ; Retreive the transaction id. This id can come from the contract
    ; proposition (original action = 1) or attached as a call data.
    (unless @txId [txId] (calldataload 0x20))
    (unless @txId (stop))

    [location] (* @txId 5)
    [acceptVotes] @@ (+ @location 3)
    [rejectVotes] @@ (+ @location 4)
    [myVote] (exp 2 (- @myIndex 1))

    ; It's a pending transaction and the participant has not voted yet
    ; Participant n°i has voted iff `votes & myVote`
    ; where `votes = acceptVotes + rejectVotes` and `myVote = 2^i`
    (when (&& (= @@@location 1) (! (& (+ @acceptVotes @rejectVotes) @myVote))) {
      ; Vote
      (if (= @action 2)
        [votes] (| @acceptVotes @myVote)
        [votes] (| @rejectVotes @myVote)
      )
      [[(+ @location @action 1)]] @votes

      ; Calculate the number of required signatures to change the state
      (if (= @action 2)
        [requiredSigs] @@1
        [requiredSigs] (+ (- @@0 @@1) 1)
      )

      ; Count the number of votes, ie the number of bits set. We use the Brian
      ; Kernighan's method:
      ; for (nbVotes = 0; votes; nbVotes++)
      ;   nbVotes &= nbVotes -1
      (for () @votes [nbVotes] (+ @nbVotes 1) [votes] (& @votes (- @votes 1)))

      ; If there are enough votes, do the job
      (when (>= @nbVotes @requiredSigs) {
        [txReceiver] [[(+ @location 1)]]
        [txAmount] [[(+ @location 2)]]

        ; Update the transaction state
        [[@location]] @action

        (if (= @action 2) {
          (if @txAmount {
            ; The transaction is accepted and its amount isn't null, send the
            ; money
            (call @txReceiver @txAmount 0 0 0 0 0)
          }
          {
            ; The transaction amount is null, that's a suicide
            (suicide @txReceiver)
          })
        }
        {
          ; The transaction is rejected, substract its amount to the global
          ; pending amount
          [[3]] (- @@3 @txAmount)
        })
      })
    })
  })
}
