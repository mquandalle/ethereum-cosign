# Server application

Currently we use a server application to persist in a publicly callable database
the cosign accounts associated to a public addresses of the cosigners. These
information are already retrievable from the blockchain but it would require to
scan all the transactions. The server only host public informations (public
keys, no IP, no name and obviously no private keys).

In its current form this server side storage isn't trustable since anybody can
announce a cosign account with the participants and the contract address they
want, ie the server does __not__ check the blockchain. XXX Maybe with
`node-ethereum`? That could introduce bugs in the user interface (you could see
addresses which aren't cosign accounts) but nothing at the contract level (you
cannot steal someone else vote).

Anyway I would prefer to use a client side storage, local to the ethereum
client, similar to what `localStorage` is in a web browser.

## Schema

```json
{
  "_id": "contractAdress",
  "participants": [
    "participant0Address",
    "participant1Address",
    ...
    "participantNAddress"
  ]
}
```
