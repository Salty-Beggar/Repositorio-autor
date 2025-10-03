#include <iostream>
#include <vector>
using namespace std;

#define MAX_N 200000

long int n, treeDP[MAX_N][2];
vector<vector<long int>> tree;

long int solveNode(long int nodeIndex, int mode) { // RIGHT_NOW: You've very likely found the right algorithm. Just make sure you're applying it correctly.
    if (tree[nodeIndex].empty()) return 0;
    if (treeDP[nodeIndex][mode] != -1) return treeDP[nodeIndex][mode];
    //cout << nodeIndex << " ";
    vector<long int> curChildren = tree[nodeIndex];
    if (mode == 0) { // nodeIndex is included.
        long int baseAmount = 0; // The amount of edges supposing you don't connect with any of them.
        bool stopMinimizing = false;
        for (long int i = 0; i < curChildren.size(); i++) {
            stopMinimizing = solveNode(curChildren[i], 1) >= solveNode(curChildren[i], 0);
            if (stopMinimizing) break;
            baseAmount += solveNode(curChildren[i], 0);
        }
        if (!stopMinimizing) {
            long int bestAmount = -1; // The biggest amount of edges that can be gathered.
            for (long int i = 0; i < curChildren.size(); i++) {
                bestAmount = 
                max(bestAmount, baseAmount - solveNode(curChildren[i], 0) + solveNode(curChildren[i], 1));
            }
            bestAmount++;
            treeDP[nodeIndex][0] = bestAmount;
            return bestAmount;
        }else {
            long int curAmount = 0;
            for (long int i = 0; i < curChildren.size(); i++) {
                curAmount += max(solveNode(curChildren[i], 0), solveNode(curChildren[i], 1));
            }
            curAmount++;
            treeDP[nodeIndex][0] = curAmount;
            return curAmount;
        }
    }
    // nodeIndex is not included.
    long int curAmount = 0;
    for (long int i = 0; i < curChildren.size(); i++) {
        curAmount += max(solveNode(curChildren[i], 0), solveNode(curChildren[i], 1));
    }
    treeDP[nodeIndex][1] = curAmount;
    return curAmount;
}

int main() {
    cin >> n;
    for (long int i = 0; i < n; i++) {
        tree.push_back({});
        treeDP[i][0] = -1;
        treeDP[i][1] = -1;
    }
    for (long int i = 0; i < n-1; i++) {
        long int u, v;
        cin >> u >> v;
        tree[u-1].push_back(v-1);
    }
    long int curMaxEdges = 0;
    for (long int i = 0; i < n; i++) {
        curMaxEdges = max(curMaxEdges, solveNode(i, 0));
        curMaxEdges = max(curMaxEdges, solveNode(i, 1));
    }
    cout << curMaxEdges;
    return 0;
}