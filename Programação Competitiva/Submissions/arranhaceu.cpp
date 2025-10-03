#include <iostream>
using namespace std;

long int MAX_LEAP = 16;
long int n, q;
int array[100000];
long int biTree[100000];

void generateBITree() {
    for (long int i = 0; i < n; i++) biTree[n] = 0;
    biTree[0] = array[0];
    for (long int i = 1; i < n; i++) {
        for (int j = i - (i&(-i))+1; j <= i; j++) {
            biTree[i] += array[j];
        }
    }
    /*for (int i = 0; i < MAX_LEAP; i++) {
        long int curBit = 1<<i;
        for (long int j = curBit; j < n; j += curBit) {
            biTree[j] += array[curBit];
        }
    }*/
}

void informarSoma(int sumRange) {
    int curSum = biTree[0];
    while (sumRange > 0) {
        curSum += biTree[sumRange];
        sumRange -= sumRange&(-sumRange);
    }
    cout << curSum << "\n";
}

void trocarMoradores(long int index, int newValue) {
    int valueDiff = newValue - array[index];
    array[index] = newValue;
    if (index == 0) {
        biTree[0] += valueDiff;
        return;
    }
    // RIGHT_NOW: Entender porque esse código funciona.
    for (long int i = index; i < n; i += (i&(-i))) {
        biTree[i] += valueDiff;
    }
}

int main()
{
    cin >> n >> q;
   
    for (int i = 0; i < n; i++) {
        cin >> array[i];
    }
   
    generateBITree();
   
    for (int i = 0; i < q; i++) {
        int type;
        cin >> type;
        if (type == 1) {
            int sumRange;
            cin >> sumRange;
            informarSoma(sumRange-1);
        }else {
            long int index;
            int newValue;
            cin >> index >> newValue;
            trocarMoradores(index-1, newValue);
        }
    }
    return 0;
}