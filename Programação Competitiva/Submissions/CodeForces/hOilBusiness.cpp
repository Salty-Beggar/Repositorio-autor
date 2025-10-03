// The problem must have had an issue with types of variables. You must make s unsigned.

#include <algorithm>
#include <iostream>
#include <vector>
#include <stack>
using namespace std;

const long long int MAX_N = 100100;
const long long int MAX_M = 100100;

long long int n;
long long int m;
long long int s;
vector<vector<long long int>> connections;
vector<long long int> removedConnectionIndexes;
long long int removedConnectionAmnt = 0;

// Disjoint set
long long int disjointSet[MAX_N], dsWeight[MAX_N];
long long int find(long long int a) {
    if (disjointSet[a] == a) return a;
    
    long long int monarch = find(disjointSet[a]);
    disjointSet[a] = monarch;
    return monarch;
}
void join(long long int u, long long int v) {
    u = find(u);
    v = find(v);
    if (u == v) return;
    if (dsWeight[u] > dsWeight[v]) {
        long long int backup = u;
        u = v;
        v = backup;
    }
    disjointSet[u] = v;
    if (dsWeight[u] == dsWeight[v]) dsWeight[v] = dsWeight[u]+1;
}
bool isJoined(long long int u, long long int v) {
    return find(u) == find(v);
}

bool comp(vector<long long int> a, vector<long long int> b) {
    return a[2] > b[2];
}

void solve() {
    if (m == n-1) return;
    sort(connections.begin(), connections.end(), comp);
    stack<long long int> candidateConnections;
    long long int mstCurSize = 0;
    for (long long int i = 0; i < m; i++) {
        vector<long long int> curConnection = connections[i];
        if (mstCurSize < n-1 && !isJoined(curConnection[0], curConnection[1])) {
            join(curConnection[0], curConnection[1]);
            mstCurSize++;
        }else {
            candidateConnections.push(i);
        }
    }
    while (!candidateConnections.empty() && (s - connections[candidateConnections.top()][2]) >= 0) {
        vector<long long int> curConnection = connections[candidateConnections.top()];
        s -= curConnection[2];
        removedConnectionAmnt++;
        removedConnectionIndexes.push_back(candidateConnections.top());
        candidateConnections.pop();
    }
}

int main() {
    cin >> n >> m >> s;
    for (long long int i = 0; i < n; i++) {
        disjointSet[i] = i;
        dsWeight[i] = 0;
    }
    for (long long int i = 0; i < m; i++) {
        long long int u, v;
        long long int w;
        cin >> u >> v >> w;
        connections.push_back({u-1, v-1, w});
    }
    solve();
    cout << removedConnectionAmnt << "\n";
    for (long long int i = 0; i < removedConnectionAmnt; i++) {
        cout << removedConnectionIndexes[i]+1 << " ";
    }
    return 0;
}