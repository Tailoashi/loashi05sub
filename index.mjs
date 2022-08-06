import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance)
const accBobs = await stdlib.newTestAccounts(6, startingBalance);
const NFT = await stdlib.launchToken(accAlice, "NFT", "NFT100", { supply: 1 });
console.log('Hello, Alice and Bobs!');

console.log('Launching...');
const ctcAlice = accAlice.contract(backend);

const showBalance = async (acc, name) => {
  const amt = await stdlib.balanceOf(acc);
  const amtNFT = await stdlib.balanceOf(acc, NFT.id);
  console.log(`${name} has ${stdlib.formatCurrency(amt)} ${stdlib.standardUnit} and ${amtNFT} of the NFT`);
};
const ctcWho = (who) =>
  accBobs[who].contract(backend, ctcAlice.getInfo());

const Bobs_tickects = async (whoi, ticketnumber) => {
  try {
    const who = accBobs[whoi];
    const acc = who.getAddress()
    const ctc = ctcWho(whoi);
    who.tokenAccept(NFT.id)
    await ctc.apis.Bobs.selectticketnum(parseInt(ticketnumber));
  } catch (error) {
    console.log(error);
  }

}


console.log('Starting backends...');
await showBalance(accBobs[0], 'Bob1')
await showBalance(accBobs[1], 'Bob2')
await showBalance(accBobs[2], 'Bob3')
await showBalance(accBobs[3], 'Bob4')
await showBalance(accBobs[4], 'Bob5')
await showBalance(accBobs[5], 'Bob6')
await Promise.all([
  backend.Alice(ctcAlice, {
    ...stdlib.hasRandom,
    nftid: NFT.id,
    winning_number: parseInt(17),
    maxnumoftickets: parseInt(6),
    seewinnum: async (dig) => {
      console.log(` The hashed value: ${dig}`)
    },
    displayguess: async (bobnum, winnum) => {
      console.log(`Guessed ${bobnum} while number is ${winnum}`)

    },
  }),
  await Bobs_tickects(0, 4),
  await Bobs_tickects(1, 24),
  await Bobs_tickects(2, 114),
  await Bobs_tickects(3, 56),
  await Bobs_tickects(4, 17),
  await Bobs_tickects(5, 6)

]);
await showBalance(accBobs[0], 'Bob1')
await showBalance(accBobs[1], 'Bob2')
await showBalance(accBobs[2], 'Bob3')
await showBalance(accBobs[3], 'Bob4')
await showBalance(accBobs[4], 'Bob5')
await showBalance(accBobs[5], 'Bob6')

console.log('Goodbye, Alice and Bob!');
process.exit()
