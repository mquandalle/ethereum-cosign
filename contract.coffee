class cosignContract extends Contract

  # Define global storage locations
  nParticipants: @storage[0]
  nRequiredSigs: @storage[1]
  nTransactions: @storage[2]
  pendingAmount: @storage[3]

  # Define constant numbers (replaced during compilation)
  STATE:
    PENDING:  1
    ACCEPTED: 2
    REJECTED: 3

  VOTE:
    ACCEPT: 2
    REJECT: 3

  ACTIONS:
    PROPOSE:    1
    VOTEACCEPT: 2
    VOTEREJECT: 3

  constructor: ->
    @nParticipants = 3
    @nRequiredSigs = 2

    @storage[-0x56b7acde001badc18e37e53f390e45be5f90f240] = 1
    @storage[-0x62e84fb46981e4a7bca6e2cb98cad77e51fc8a36] = 2
    @storage[-0x6bca5f312d950c6d9aa973c776700e00ae225483] = 3

    # Optional: name registration
    # @msg(0x929b11b8eeea00966e873a241d4b67f7540d1f38, 0, 0, "chronos")

  # Public method: @data[0] = @ACTIONS.PROPOSE
  propose: (txReceiver, txAmount, nextAction) ->
    # Check if the contract contains enough "none-pending" money
    @stop() if @balance - @pendingAmount < txAmount
    myIndex = @getCallerIndex(@caller)

    # Update the number of transactions
    txId = ++@nTransactions

    # Add to the pending money
    @pendingAmount += txAmount

    # Set the state, the receiver, and the amount
    location = @getTransactionLoc(txId)
    @storage[location] = @STATE.PENDING
    @storage[location + 1] = txReceiver
    @storage[location + 2] = txAmount

    if nextAction == @ACTIONS.VOTEACCEPT || nextAction == @ACTIONS.VOTEREJECT
      @vote(myIndex, txId, nextAction)

    return txId

  # Public method: @data[0] = @ACTIONS.VOTEACCEPT
  voteaccept: (txId) ->
    @vote(@getCallerIndex(@caller), txId, @ACTIONS.VOTEACCEPT)

  # Public method: @data[0] = @ACTIONS.REJECT
  votereject: (txId) ->
    @vote(@getCallerIndex(@caller), txId, @ACTIONS.VOTEREJECT)

  getCallerIndex: (caller) ->
    i = @storage[-@tx.origin]
    @stop() unless i
    return i

  getTransactionLoc: (txId) ->
    return txId * 5

  vote: (myIndex, txId, vote) ->
    # Check that this is a pending transaction
    @stop() unless txId
    location = @getTransactionLoc(txId)
    @stop() unless @storage[location] == @state.pending

    # Participant n°i has voted iff `votes & myVote`
    # where `votes = acceptVotes + rejectVotes` and `myVote = 2^i`
    acceptVotes = @storage[location + 3]
    rejectVotes = @storage[location + 4]
    myVote = 2**(myIndex - 1)
    @stop() if (acceptVotes + rejectVotes) & myVote

    # Vote and calculate the number of required signatures to change the state
    if vote == @vote.accept
      votes = acceptVotes |= myVote
      requiredSigs = @nRequiredSigs
    else
      votes = rejectVotes |= myVote
      requiredSigs = @nParticipants - @nRequiredSigs + 1

    # Count the number of votes, ie the number of bits set.
    # We use Brian Kernighan's method:
    while votes
      votes &= votes - 1
      nbVotes++

    # If there are enough votes, do the job
    if nbVotes > requiredSigs
      txReceiver = @storage[location + 1]
      txAmount = @storage[location + 2]

      # Update the transaction state
      @storage[location] = vote

      if vote == @VOTE.ACCEPT
        if txAmount
          # The transaction is accepted and its amount isn't null, send the
          # money
          @send(txReceiver, txAmount)
        else
          # The transaction amount is null, that's a suicide
          @suicide(txReceiver)
      else
        # The transaction is rejected, substract its amount to the global
        # pending amount
        @pendingAmount -= txAmount
