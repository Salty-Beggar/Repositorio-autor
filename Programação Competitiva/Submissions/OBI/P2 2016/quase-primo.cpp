#include <iostream>
#include <vector>
using namespace std;


long long int n;
int k;
long long int almostPrimeAmount = 0;
long long int primes[40];
bool primeBitmask[1<<40];

void _almostPrime(int i, long long int curFactor, int factorAmount, long long int bitmask) {
    if (curFactor > n) return;
    if (factorAmount != 0 && !primeBitmask[bitmask]) {
        //cout << curFactor << "\n";
        if (factorAmount%2 == 0) almostPrimeAmount -= n/curFactor;
        else almostPrimeAmount += n/curFactor;
    }
    
    if (i == k) return;

    primeBitmask[bitmask] = true;
    _almostPrime(i+1, curFactor, factorAmount, bitmask);
    _almostPrime(i+1, curFactor*primes[i], factorAmount+1, bitmask|(1<<i));
}

int main() {
    cin >> n >> k;
    for (int i = 0; i < k; i++) cin >> primes[i];
    _almostPrime(0, 1, 0, 0);
    
    cout << n-almostPrimeAmount;
    
    return 0;
}