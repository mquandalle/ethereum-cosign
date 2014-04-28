# Cosign: mutli-signatures for Ethereum

Unlike Bitcoin and other cryptocurrencies, Ethereum doesn't implement a
[multisignatures](http://bitcoin.stackexchange.com/questions/3718/what-are-multi-signature-transactions)
feature. Instead Ethereum provide a
[turing-complete](http://en.wikipedia.org/wiki/Turing_completeness) scripting
language with which we can build whatever we want (including multisigs).

[See the lisp-like version of the contract](/contract.lisp).

## Contract persistent storage

### Contract global data

```lisp
[[0]]          ; Number of participants (n < 256)
[[1]]          ; Number of signatures required to accept a transaction (> 0)
[[2]]          ; Number of transaction proposals
[[3]]          ; Amount of money frozen in pending transactions
```

Keys `0` and `1` must be defined in the initialization phase and are immutable.
Keys `2` and `3` start at `0` and don't need to be initialized.

### Participants indexes

```lisp
[[-addr1]]       ; = 1
[[-addr2]]       ; = 2
[[-addri]]       ; = i (i <= n)
```

These keys must be defined in the initialization phase. The value is a number
in the `[1, 256]` range called _participant index_. If two addresses share the
same index, only the first one to vote will count.

We use negative keys to avoid collision with the transactions data (see below).
The biggest address is `(2^8)^20 = 2^160` so the maximum number of transaction without risking a storage collision is `(2^256 - 2^160)/5` which is superior to
`10^77`.

### Cosign transactions data

```lisp
[[t*5]]         ; Transaction n°t: state (t > 0)
[[t*5+1]]       ; Transaction n°t: receiver
[[t*5+2]]       ; Transaction n°t: amount
[[t*5+3]]       ; Transaction n°t: accept votes
[[t*5+4]]       ; Transaction n°t: reject votes
```

These storage values contain:

* __state__:
  * `0x01` pending
  * `0x02` accepted
  * `0x03` rejected
* __receiver__: ethereum address
* __amount__: integer, number of wei (`0` => suicide)
* __accept votes__: a bitwise number. Imagine that voter 0 and 3 voted "accept",
  and other participants hasn't voted yet. We encode that state as
  `2^0 + 2^3 = 0000...0001001`. That's why we have a 255 voters limit.
* __reject votes__: same as "accept votes" but for "reject"

## Possible contract calls

### Propose

```
0x00: 0x01
0x20: address
0x40: amount (0 = suicide)
0x60: nextAction (2 = accept, 3 = reject) [optional]
```

### Accept

```
0x00: 0x02
0x20: transactionId
```

### Reject

```
0x00: 0x03
0x20: transactionId
```

## Contributing

Contributions are welcome, whether it is for a
[bug report](https://github.com/mquandalle/ethereum-cosign/issues/new), a fix or
a new functionality proposition. Both the contract and the Ðapp are published
under the [MIT license](/LICENSE). Take a look at the [Todo list](/TODO.md).

### Modifying the Ðapp (XXX Not yet)

The Cosign Ðapp associate to the contract is built using the
[Meteor](https://www.meteor.com) framework. If you want to contribute,

1. Install Meteor
   ```
   $ curl https://install.meteor.com/ | sh
   ```
2. Download the application
   ```
   git clone https://github.com/mquandalle/ethereum-cosign
   ```
3. Start the app
   ```
   cd ethereum-cosign && meteor
   ```

### Tips

If you want to buy me a beer, I proudly accept bitcoin tips:
[1Jade7Fscsx2bF13iFVVFvcSUhe7eLJgSy](https://blockchain.info/address/1Jade7Fscsx2bF13iFVVFvcSUhe7eLJgSy)
