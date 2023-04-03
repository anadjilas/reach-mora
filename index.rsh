'reach 0.1';

const Player = {
  ...hasRandom,
  getHand: Fun([], UInt),
  getGuess: Fun([], UInt),
  seeOutcome: Fun([UInt], Null)
}

export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    // Specify Alice's interact interface here
    ...Player, 
    wager: UInt, 
  })
  const Bob = Participant('Bob', {
    // Specify Bob's interact interface here
    ...Player, 
    acceptWager: Fun([UInt], Null)
  })
  init();

  Alice.only(() => {
    //interact pokrece interakciju sa frontom i vraca hash-iranu vrijednost
    //declassify pretvara u citljiv format
    
    const amount  = declassify(interact.wager);
  })
  
  // The first one to publish deploys the contract
  Alice.publish(amount)
      .pay(amount);
  commit();

  //unknowable(Bob, Alice(handAlice));

  Bob.only(() => {
    //interact pokrece interakciju sa frontom i vraca hash-iranu vrijednost
    //declassify pretvara u citljiv format
    interact.acceptWager(amount);
  })
  // The second one to publish always attaches
  Bob.pay(amount);

  var rezultat = 1;
  invariant(balance() == 2*amount);
  //pocetak petlje
  while(!(rezultat == 0 || rezultat == 2)){

    
  commit();

  //Alice igra prvi put
  Alice.only(() =>{
        //interact pokrece interakciju sa frontom i vraca hash-iranu vrijednost
    //declassify pretvara u citljiv format
    const _handAlice = interact.getHand();
    const [_commitAlice, _saltAlice] = makeCommitment(interact, _handAlice);
    const commitAlice = declassify(_commitAlice);
    const guessAlice = declassify(interact.getGuess());
  })

  Alice.publish(commitAlice, guessAlice);
  commit();

  //Bob igra
  Bob.only(()=>{
    const handBob = declassify(interact.getHand());
    const guessBob = declassify(interact.getGuess());
  })

  Bob.publish(handBob, guessBob);
  commit();

  Alice.only(() => {
    const saltAlice = declassify(_saltAlice);
    const handAlice = declassify(_handAlice);
  })

  Alice.publish(saltAlice, handAlice);
  checkCommitment(commitAlice, saltAlice, handAlice);
  

  rezultat = (guessAlice == guessBob) ? 1 
    : (guessAlice == (handAlice + handBob)) ? 2
    : (guessBob == (handAlice + handBob)) ? 0
    : 1; 

    continue;
} //kraj petlje
//provjeravamo nasu pretpostavku
assert(rezultat == 0 || rezultat == 2);
  //outcome moze biti 0 ili 1 ili 2
 
 // const [amtAlice, amtBob] = (outcome == 1) ? [1, 1]
   // : (outcome == 0) ? [0, 2] 
  //  : [2, 0]

//  transfer(amtAlice*amount).to(Alice);
 // transfer(amtBob*amount).to(Bob);
  transfer(2*amount).to(rezultat == 0 ? Bob : Alice);

  commit();

  each([Alice, Bob], () => {
    interact.seeOutcome(rezultat);
  })
  // write your program here
  exit();
});
