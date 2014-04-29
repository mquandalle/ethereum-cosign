Cosign = new Meteor.Collection("cosigns")

Meteor.methods
  createContract: (contractAddress, participants) ->
    check contractAddress, String
    check participants, [String]
    Cosign.insert
      _id: contractAddress
      participants: participants

Meteor.publish "myCosigns", (address) ->
  check address, String
  Cosign.find
    participants: address
