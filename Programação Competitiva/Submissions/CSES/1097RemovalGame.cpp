#include <iostream>
#include <algorithm>
using namespace std;

#define MAX_N 5000

int n;
long long int arr[MAX_N];
long long int dp[MAX_N][MAX_N][2];

void defineDP() {
    for (int i = 0; i < n; i++) {
        dp[i][i][0] = arr[i];
        dp[i][i][1] = 0;
    }
    for (int j = 1; j < n; j++) {
        for (int x = 0; x < n-j; x++) {
            int y = x+j;
            bool isXChoiceBetter = (dp[x+1][y][1] + arr[x]) > (dp[x][y-1][1] + arr[y]);
            dp[x][y][0] = (isXChoiceBetter) ? dp[x+1][y][1]+arr[x] : dp[x][y-1][1]+arr[y];
            dp[x][y][1] = (isXChoiceBetter) ? dp[x+1][y][0] : dp[x][y-1][0];
        }
    }
}

int main() {
    cin >> n;
    for (int i = 0; i < n; i++) {
        cin >> arr[i];
    }
    
    defineDP();
    cout << dp[0][n-1][0];
    
    return 0;
}