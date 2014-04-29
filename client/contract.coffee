Meteor.startup ->
  alert "This application must be run in a ethereum client,
         not a classical web browser." unless window.eth?

class CosignContract

  constructor: (contractAddress) ->
    @address = key.addressOf(contractAddress)
    @balance = balanceAt(@address)
    @nbParticipants = eth.storageAt(@address, u256.value(0))
    @requiredSigs = eth.storageAt(@address, u256.value(1))

    @participants = [eth.storageAt(@address, u256.value(10 + i)) for i in _.range(nbParticipants)]
    @transactions = []

  create: (requiredSigs, participants, publicName = null) ->
    # nbParticipants = participants.length

    # Generate init bytes
    cosignBody = _.reduce [
      "330356600546005363000105900600356020546016020530c0d6300089596020"
      "35604054604035606054603566080546060536080533031030a0d0d630008959"
      "601602560160a05460560a0530260c05460a0536025760605360805301603576"
      "0160c0535760405360160c053015760605360260c05301576060356020546016"
      "026020530c630009e59506036020530c0d630019b5960a05363000b459602035"
      "60a05460a05363000be590060560a0530260c05460360c053015660e05460460"
      "c0530156611054601600530360208611205460060160c053560c6300180d5950"
      "611205361105360e05301100d0d630019b596026020530c630012e5961120536"
      "11053116114054630013a58611205360e053116114054611405360160205360c"
      "05301576026020530c630016859601601566005603016116054630016f586015"
      "6611605461140530d630019b5960161140530361140531061140546016118053"
      "016118054630016f580000000000000000000000000000000000000000000000"
      ], (prevBytes, next) ->
        nextBytes =  u256.bytesOf(u256.fromHex(next))
        if prevBytes then bytes.concat(prevBytes, nextBytes) else nextBytes
      , null

    # Copy body bytes from a hard coded location
    eth.create(
      key.secret(eth.keys()[0]),
      u256.ether(0),
      cosignBody,
       u256.bytesOf(u256.value(0)),
      0,
      0
    )

  propose: (address, amount) ->
    eth.transact(_sec, _xValue, _aDest, _bData, _xGas, _xGasPrice)

  vote: (txId, voteId) ->
    eth.transact(_sec, _xValue, _aDest, _bData, _xGas, _xGasPrice)

  voteAccept: (txId) -> @vote(txId, 2)
  voteReject: (txId) -> @vote(txId, 3)
