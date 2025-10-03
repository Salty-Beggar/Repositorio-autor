#include <iostream>
using namespace std;

int t;
const int MAX_LEAP = 16;
long int n, q;
const long int MAX_N = 200000;
long int array[MAX_N];
long int biTree[MAX_N];

long long int getSumRange(long int range) {
    long long int curSum = 0;
    for (long long int i = range+1; i > 0; i -= (i&-i)) {
        curSum += biTree[i-1];
    }
    
    return curSum;
}

void changeValue(long long int index, int addition) {
    for (long long int i = index+1; i <= MAX_N; i += (i&-i)) {
        biTree[i-1] += addition;
    }
}

void prepareBITree() {
    for (long int i = 0; i < MAX_N; i++) biTree[i] = 0;
    for (long int i = 1; i <= n; i++) {
        changeValue(i-1, 1);
    }
}

void popMovieStack(long int poppedMovie) {
    
}

int main() {
    cin >> t;
    for (int z = 0; z < t; z++) {
        cin >> n >> q;
        
        prepareBITree();
        
        for (int i = 0; i < n; i++) {
            array[i] = n-i-1;
        }
        
        for (int i = 0; i < q; i++) {
            long int poppedMovie;
            cin >> poppedMovie;
            
            //cout << array[i] << " " << i << " ";
            
            //cout << ":burh\n";
            
            int poppedMovieValue = n-getSumRange(array[poppedMovie-1]);
            cout << poppedMovieValue << " ";
            changeValue(array[poppedMovie-1], -1);
            array[poppedMovie-1] = n+i;
            changeValue(array[poppedMovie-1], 1);
            
        }
        cout << "\n";
    }
    return 0;
}