# Smart contract

* Add an option for the proposer to "accept" or "reject" his proposition in the
  same contract call.
* Remove the unnecessary [0] "nbParticipants"? We could just count the number of
  signatures.
* Should we use Serpent instead of LLL?

# Ðapp

* How do we "instantiate" this smart contract? We need to generate the `init`
  block with the user data and to copy the `body` block from a hard coded
  source.
* How do we store the different cosign contracts a user participate in? Do we
  need some kind of "accounting"? If so do we need to store data on a server? Or
  on a contract storage? Otherwise should we just use local storage?
* Build the Meteor app!
* Implement Reactivity - Real time updates
