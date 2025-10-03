#include <iostream>
#include <vector>
#include <stack>
using namespace std;

int n;
vector<int> stacks;

int main() {
    cin >> n;
    for (int i = 0; i < n; i++) {
        int curItem;
        cin >> curItem;
        
        vector<int>::iterator it = lower_bound(stacks.begin(), stacks.end(), curItem);
        
        if (it == stacks.end()) {
            stacks.push_back(curItem);
        }else {
            *it = curItem;
        }
    }
    
    cout << stacks.size();
    
    return 0;
}