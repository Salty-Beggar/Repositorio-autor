#include <iostream>
using namespace std;

struct Pt {
    long long int x, y;
    Pt(long long int _x = 0, long long int _y = 0) : x(_x), y(_y) {}
    Pt operator+(const Pt& o) {
        return Pt(x+o.x, y+o.y);
    }
    Pt operator-(const Pt& o) {
        return Pt(x-o.x, y-o.y);
    }
    long long operator/(const Pt& o) {
        return x*o.y - y*o.x;
    }
};

int main() {
    int n;
    cin >> n;
    long long int totalArea = 0;
    for (int i = 0; i < n; i++) {
        int p;
        cin >> p;
        
        Pt pivotPoint;
        cin >> pivotPoint.x >> pivotPoint.y;
        Pt prevPoint;
        cin >> prevPoint.x >> prevPoint.y;
        long long int curArea = 0;
        for (int j = 2; j < p; j++) {
            Pt curPoint;
            cin >> curPoint.x >> curPoint.y;
            curArea += (curPoint-pivotPoint)/(prevPoint-pivotPoint);
            prevPoint = curPoint;
        }
        totalArea += abs(curArea);
    }
    cout << totalArea/2;
    return 0;
}