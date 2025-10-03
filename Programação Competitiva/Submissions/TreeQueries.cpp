
#include <iostream>
#include <queue>
#include <vector>
using namespace std;

// RIGHT_NOW: Some parts must have long ints instead of ints.

void solve(int n, long long int parent[][2], vector<vector<vector<long long int>>> children, int q, int queries[][2]) 
{
    int MAX_LEAP = 16;
    long long int binaryLeap[n][MAX_LEAP][2];
    for (int i = 0; i < n; i++) {
        binaryLeap[i][0][0] = parent[i][0];
        binaryLeap[i][0][1] = parent[i][1];
    }
    for (int j = 1; j < MAX_LEAP; j++) {
        for (int i = 0; i < n; i++) {
            int prevLeap = binaryLeap[i][j-1][0];
            if (prevLeap != -1) {
                binaryLeap[i][j][0] = binaryLeap[prevLeap][j-1][0];
                binaryLeap[i][j][1] = binaryLeap[i][j-1][1]+binaryLeap[prevLeap][j-1][1];
            }else {
                binaryLeap[i][j][0] = prevLeap;
            }
        }
    }
    
    // Finding the depth of each node.
    int nodeDepth[n];
    int curDepth = 0;
    queue<int> bfs;
    bfs.push(0);
    while (!bfs.empty()) {
        int curBFSSize = bfs.size();
        for (int i = 0; i < curBFSSize; i++) {
            int curNode = bfs.front();
            bfs.pop();
            nodeDepth[curNode] = curDepth;
            for (int j = 0; j < children[curNode].size(); j++) {
                bfs.push(children[curNode][j][0]);
            }
        }
        curDepth++;
    }
    
    for (int i = 0; i < q; i++) {
        int curQuery[2] = {queries[i][0], queries[i][1]};
        int u = curQuery[0];
        int v = curQuery[1];
        
        long long int curLength = 0;
        
        if (nodeDepth[u] < nodeDepth[v]) {
            int k = u;
            u = v;
            v = k;
        }
        
        if (nodeDepth[u] != nodeDepth[v]) {
            int depthDiff = nodeDepth[u] - nodeDepth[v];
            for (int j = 0; j < MAX_LEAP; j++) {
                int curBit = 1<<j;
                if ((depthDiff&curBit) == curBit) {
                    curLength += binaryLeap[u][j][1];
                    u = binaryLeap[u][j][0];
                }
            }
        }
        if (u != 0) {
            for (int j = 0; j < MAX_LEAP; j++) {
                if (binaryLeap[u][j][0] != binaryLeap[v][j][0]) {
                    //cout << "Penis\n";
                    curLength += binaryLeap[u][j][1];
                    curLength += binaryLeap[v][j][1];
                    u = binaryLeap[u][j][0];
                    v = binaryLeap[v][j][0];
                }
            }
            curLength += binaryLeap[u][0][1];
            curLength += binaryLeap[v][0][1];
        }
        cout << curLength << " ";
    }
}

int main()
{
    while (true) {
        int n, q;
        cin >> n;
        if (n == 0) break;
        long long int parent[n][2];
        parent[0][0] = -1;
        vector<vector<vector<long long int>>> children;
        for (int i = 0; i < n; i++) {
            children.push_back({});
        }
        for (int i = 1; i < n; i++) {
            long long int v, w;
            cin >> v >> w;
            parent[i][0] = v;
            parent[i][1] = w;
            children[v].push_back({i, w});
        }
        
        cin >> q;
        int queries[q][2];
        for (int i = 0; i < q; i++) {
            cin >> queries[i][0] >> queries[i][1];
        }
        
        solve(n, parent, children, q, queries);
        cout << "\n";
    }
    return 0;
}