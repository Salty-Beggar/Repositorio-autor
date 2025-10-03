#include <iostream>
#include <vector>
#include <stack>
using namespace std;

int n;
vector<int> stacks;
vector<int> arr;

bool comp(const int &a, const int &b) {
    return arr[a] < arr[b];
}

int main() {
    cin >> n;
    for (int i = 0; i < n; i++) {
        int curItem;
        cin >> curItem;
        arr.push_back(curItem);

        vector<int>::iterator it = custom_lower_bound(stacks.begin(), stacks.end(), i);
        
        if (it == stacks.end()) {
            stacks.push_back(i);
        }else {
            *it = i;
        }
    }
    
    cout << stacks.size() << "\n";
    for (int i = 0; i < n; i++) cout << stacks[i] << " ";
    
    return 0;
}

// RIGHT_NOW: Check if this function is returning the lower bound or the upper one.
vector<int>::iterator custom_lower_bound(vector<int>::iterator __first, vector<int>::iterator __last, const int &val) {
    vector<int>::iterator __middle;
    while (__last-__first != 1) {
        __middle = __first+(__last-__first)/2;
        if (arr[*__middle] < arr[val]) {
            __first = __middle;
        }else {
            __last = __middle;
        }
    }

    return __middle;
}