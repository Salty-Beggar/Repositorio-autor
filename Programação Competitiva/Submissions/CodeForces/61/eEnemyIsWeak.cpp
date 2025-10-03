#include <iostream>
#include <vector>
#include <queue>
#include <unordered_map>
#include <algorithm>
using namespace std;

#define MAX_N 1000100

long int n;
long long int countsBITree[MAX_N];
long long int inversionsBITree[MAX_N];
void biTreeUpdate(long long int (&biTree)[MAX_N], long long int index, long long int add) {
    index++;
    for (; index <= n; index += index&-index) {
        biTree[index-1] += add;
    }
}
long long int biTreeSum(long long int (&biTree)[MAX_N], long long int index) {
    long long int curSum = 0;
    index++;
    for (; index > 0; index -= index&-index) {
        curSum += biTree[index-1];
    }
    return curSum;
}

int main() {
    cin >> n;
    
    vector<long long int> powerVector;
    vector<long long int> powerVectorOrdered;
    for (long int i = 0; i < n; i++) {
        long long int p;
        cin >> p;
        powerVector.push_back(p);
        powerVectorOrdered.push_back(p);
    }
    
    sort(powerVectorOrdered.begin(), powerVectorOrdered.end());
    unordered_map<long long int, long int> compressionMap;
    for (long int i = 0; i < n; i++) {
        compressionMap.insert({powerVectorOrdered[i], i});
    }
    
    long long int curInversions = 0;
    for (long int i = n-1; i >= 0; i--) {
        long int pRelative = compressionMap[powerVector[i]];
        long long int biggerValueCount = biTreeSum(countsBITree, pRelative);
        long long int biggerValueInversionCount = biTreeSum(inversionsBITree, pRelative);
        ///cout << biggerValueCount << " ";
        curInversions += biggerValueInversionCount;
        biTreeUpdate(countsBITree, pRelative, 1);
        biTreeUpdate(inversionsBITree, pRelative, biggerValueCount);
    }
    
    
    cout << curInversions;
    
    return 0;
}