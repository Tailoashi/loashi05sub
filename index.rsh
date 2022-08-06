'reach 0.1';
const [isOutcome, Bob_GUESSED_RIGHT, NO_ONE_GUESSED_RIGHT] = makeEnum(2)
export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...hasRandom,
    nftid: Token,
    winning_number: UInt,
    maxnumoftickets: UInt,
    seewinnum: Fun([Digest], Null),
    displayguess: Fun([UInt, UInt], Null)
  });
  const Bobs = API('Bobs', {
    selectticketnum: Fun([UInt], Null)
  });
  init();

  Alice.only(() => {
    const NftId = declassify(interact.nftid)
    const numofticks = declassify(interact.maxnumoftickets)
    const _winning_num = interact.winning_number
    const [_commitwinnum, _saltwinnum] = makeCommitment(interact, _winning_num)
    const commitwinnum = declassify(_commitwinnum)
  })
  Alice.publish(NftId, numofticks, commitwinnum)
  commit()

  Alice.only(() => {
    const seenum = declassify(interact.seewinnum(commitwinnum))
  })
  Alice.publish(seenum)
  const usermap = new Map(Address, UInt)
  const [num_count, Addresses, numofraffle] =
    parallelReduce([0, Array.replicate(6, Alice), Array.replicate(6, 0)])
      .invariant(balance(NftId) == 0)
      .while(num_count < 6)
      .api(
        Bobs.selectticketnum,
        (num) => {
          check(num > 0, 'number should be greater than zero')
        },
        (_) => 0,
        (num, k) => {
          k(null);
          usermap[this] = num
          return [num_count + 1, Addresses.set(num_count, this), numofraffle.set(num_count, num)]
        }
      )
  commit()
  Alice.only(() => {
    const saltwinnum = declassify(_saltwinnum)
    const winnum = declassify(_winning_num)
  })
  Alice.publish(saltwinnum, winnum)
  checkCommitment(commitwinnum, saltwinnum, winnum)
  var [counts, bobs_adddress, bobs_tickets] = [0, Addresses, numofraffle]
  invariant(balance(NftId) == 0)
  while (counts < 6) {
    commit()
    Alice.publish()
    if (bobs_tickets[counts] == winnum) {
      commit()
      Alice.only(() => {
        const guess = declassify(interact.displayguess(bobs_tickets[counts], winnum))
      })
      Alice.publish(guess)
        .pay([[1, NftId]])
      transfer([[1, NftId]]).to(bobs_adddress[counts])

    } else {
      commit()
      Alice.only(() => {
        const guess = declassify(interact.displayguess(bobs_tickets[counts], winnum))
      })
      Alice.publish(guess)
    }

    [counts, bobs_adddress, bobs_tickets] = [counts + 1, bobs_adddress, bobs_tickets]
    continue
  }
  transfer(balance()).to(Alice)
  commit()

  exit();
});
