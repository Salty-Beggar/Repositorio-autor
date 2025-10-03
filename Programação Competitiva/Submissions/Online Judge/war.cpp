#include <iostream>
using namespace std;


const int MAX_N = 9999;
int n, disjointSet[MAX_N], dsWeight[MAX_N], dsEnemy[MAX_N];

int findMonarch(int node) {
    if (disjointSet[node] == node) return node;
    
    int monarchNode = findMonarch(disjointSet[node]);
    disjointSet[node] = monarchNode;
    return monarchNode;
}

bool joinFriend(int node1, int node2) {
    int _u = findMonarch(node1); // Node 1's monarch.
    int _v = findMonarch(node2); // Node 2's monarch.
    
    if (_u == _v) return true;
    
    if (dsWeight[_u] > dsWeight[_v]) {
        int _backup = _u;
        _u = _v;
        _v = _backup;
    }
    
    if (dsEnemy[_u] == _v) return false;
    
    int _uEnemy = dsEnemy[_u];
    int _vEnemy = dsEnemy[_v];
    if (_vEnemy == -1) {
        dsEnemy[_v] = _uEnemy;
    }else if (_uEnemy != -1 && _vEnemy != -1 && _uEnemy != _vEnemy) {
        dsEnemy[_uEnemy] = _v;
        dsEnemy[_vEnemy] = _v;
        joinFriend(_uEnemy, _vEnemy);
        dsEnemy[_v] = findMonarch(_uEnemy);
    }
    
    disjointSet[_u] = _v;
    dsWeight[_v] = dsWeight[_u]+1;
    return true;
}

bool joinEnemy(int node1, int node2) {
    int _u = findMonarch(node1); // Node 1's monarch.
    int _v = findMonarch(node2); // Node 2's monarch.
    
    if (dsEnemy[_u] == _v) return true;
    if (_u == _v) return false;
    
    int _uEnemy = dsEnemy[_u];
    int _vEnemy = dsEnemy[_v];
    if (_uEnemy == -1 && _vEnemy == -1) {
        dsEnemy[_u] = _v;
        dsEnemy[_v] = _u;
    }else if (_uEnemy != -1 && _vEnemy != -1) {
        joinFriend(_uEnemy, _v);
    }else {
        if (_uEnemy == -1) joinFriend(_u, _vEnemy);
        else joinFriend(_v, _uEnemy);
    }
    return true;
}

bool isFriendsForSure(int node1, int node2) {
    if (findMonarch(node1) == findMonarch(node2)) return true;
    return false;
}

bool isEnemiesForSure(int node1, int node2) {
    if (dsEnemy[findMonarch(node1)] == findMonarch(node2)) return true;
    return false;
}

void initializeDisjointSet() {
    for (int i = 0; i < n; i++) {
        disjointSet[i] = i;
        dsWeight[i] = 0;
        dsEnemy[i] = -1;
    }
}

int main() {
    cin >> n;
    initializeDisjointSet();
    int queryType, u, v;
    do {
        cin >> queryType >> u >> v;
        switch (queryType) {
            case 1: // SetFriends
                if (!joinFriend(u, v)) cout << "-1\n";
                break;
            case 2: // SetEnemies
                if (!joinEnemy(u, v)) cout << "-1\n";
                break;
            case 3: // IsFriends
                cout << ((isFriendsForSure(u, v)) ? 1 : 0) << "\n";
                break;
            case 4: // IsEnemies
                cout << ((isEnemiesForSure(u, v)) ? 1 : 0) << "\n";
                break;
        }
    }while (queryType != 0);
}