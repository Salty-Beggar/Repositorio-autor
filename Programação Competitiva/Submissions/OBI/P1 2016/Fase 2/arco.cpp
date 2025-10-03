#include <iostream>
#include <vector>
#include <algorithm>
#include <unordered_map>
using namespace std;

#define MAX_N 100100

typedef pair<long long int, long int> pll;

long int biTree[MAX_N]; // This binary indexed tree will store the amount of struck arrows per distance from center.
long int compressedDists[MAX_N];
unordered_map<long long int, long int> compressionMap; // Maps a distance's value to its position at compressedDists.
long int n;

// Binary Indexed Tree
long int biTreeSum(long int index) {
    long int curSum = 0;
    index++;
    for (; index > 0; index -= index&-index) {
        curSum += biTree[index-1];
    }
    return curSum;
}
void biTreeUpdate(long int index, long int value) {
    index++;
    for (; index <= n; index += index&-index) {
        biTree[index-1] += value;
    }
}

int main() {
    cin >> n;
    for (long int i = 0; i < n; i++) biTree[i] = 0;
    
    long long int queries[n];
    vector<long long int> queriesOrdered;
    for (long int i = 0; i < n; i++) {
        long long int x, y;
        cin >> x >> y;
        queries[i] = x*x+y*y;
        queriesOrdered.push_back(queries[i]);
    }
    
    sort(queriesOrdered.begin(), queriesOrdered.end());
    for (long int i = 0; i < n; i++) {
        compressionMap.insert({queriesOrdered[i], i});
    }
    
    long long int curPenalty = 0;
    for (long int i = 0; i < n; i++) {
        long int curCompressedItem = compressionMap[queries[i]];
        curPenalty += biTreeSum(curCompressedItem);
        biTreeUpdate(curCompressedItem, 1);
    }
    
    cout << curPenalty;
    
    return 0;
}