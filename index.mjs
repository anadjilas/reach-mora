import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);



const startingBalance = stdlib.parseCurrency(100);

const [ accAlice, accBob ] =
  await stdlib.newTestAccounts(2, startingBalance);
console.log('Hello, Alice and Bob!');

console.log('Launching...');
const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

// hand moze biti 0-5 
// guess moze biti 0-10
const OUTCOME = ['Bob pobjedio', 'Nerjeseno', 'Alice pobjedila'];
const Player = (Who) => ({
  getHand: () => {
    const hand = Math.floor(Math.random()*6); 
    console.log(`${Who} je odigrao ${hand}`);
    return hand;
  },
  getGuess: () => {
    const guess = Math.floor(Math.random()*11); 
    console.log(`${Who} je pogadjao ${guess}`);
    return guess;
  },
  seeOutcome: (outcome) => {
    console.log(`${Who} je video da je rezultat ${OUTCOME[outcome]}`);

  }
});

console.log('Starting backends...');
await Promise.all([
  backend.Alice(ctcAlice, {
    ...stdlib.hasRandom,
    // implement Alice's interact object here
    ...Player('Alice'), 
    wager: stdlib.parseCurrency(5)
  }),
  backend.Bob(ctcBob, {
    ...stdlib.hasRandom,
    // implement Bob's interact object here
    ...Player('Bob'),
    acceptWager: (amt) =>{
      const amount = stdlib.formatCurrency(amt, 4);
      console.log(`Bob prihvata ulog od ${amount}`)
    }
  }),
]);

console.log('Goodbye, Alice and Bob!');
