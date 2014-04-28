{
  [[0]] 3 ; Number of participants (max 255)
  [[1]] 2 ; Number of required signatures

  [[10]] ADDRESS0
  [[11]] ADDRESS1
  [[12]] ADDRESS2

  ;; Optional: name registration
  ;[0] "Public name"
  ;(call 0x929b11b8eeea00966e873a241d4b67f7540d1f38 0 0 0 32 0 0)
}

{
  [nbParticipants] @@0

  ; Loop over the participants list until we find the caller
  ; @i is the participant index
  (for () (< @i @nbParticipants) [i] (+ @i 1) {
    (when (= (caller) @@(+ 10 @i)) {
      [action] (calldataload 0x00)

      ; Propose a new transaction
      (when (= @action 1) {
        [txReceiver] (calldataload 0x20)
        [txAmount] (calldataload 0x40)
        [pendingAmount] @@3

        ; Check if the contract contains enough "none-pending" money
        (when (>= (- (balance (address)) @pendingAmount) @txAmount) {
          ; Calculate the transaction location
          [txId] @@2
          [location] (* (+ @txId 1) 100)

          ; Bump the number of transactions
          [[2]] (+ @txId 1)

          ; Add to the pending money
          [[3]] (+ @pendingAmount @txAmount)

          ; Set the state (1: "pending"), the receiver and the amount
          [[@location]] 1
          [[(+ @location 1)]] @txReceiver
          [[(+ @location 2)]] @txAmount
        })
      })

      ; Accept (2) or reject (3)
      (when (|| (= @action 2) (= @action 3)) {
        [txId] (calldataload 0x20)
        [location] (+ (* @txId 10) 1000)
        [acceptVotes] @@ (+ @location 3)
        [rejectVotes] @@ (+ @location 4)
        [myVote] (exp 2 @i)

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
            [requiredSigs] (+ (- @nbParticipants @@1) 1)
          )

          ; Count the number of votes, ie the number of bits set. We use the
          ; Brian Kernighan's method:
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
                ; The transaction is accepted and its amount isn't null,
                ; send the money
                (call @txReceiver @txAmount 0 0 0 0 0)
              }
              {
                ; The transaction amount is null, that's a suicide
                (suicide @txReceiver)
              })
            }
            {
              ; The transaction is rejected, substract its amount to the
              ; global pending amount
              [pendingAmount] @@3
              [[3]] (- @pendingAmount @txAmount)
            })
          })
        })
      })
      (stop) ; Break the main loop
    })
  })
}
