#include <iostream>
using namespace std;

#define p1 pts[0]
#define p2 pts[1]
#define p3 pts[2]
#define p4 pts[3]
#define p5 pts[4]
#define p6 pts[5]
#define p7 pts[6]

#define abort {cout << "N";return 0;}

struct Pt {
    long long int x, y;
    
    Pt(long long int _x = 0, long long int _y = 0) : x(_x), y(_y) {}
    Pt operator+(const Pt& a) {return Pt(x+a.x, y+a.y);}
    Pt operator-(const Pt& a) {return Pt(x-a.x, y-a.y);}
    Pt operator/(const long long int a) {return Pt(x/a, y/a);}
    Pt operator*(const long long int a) {return Pt(x*a, y*a);}
    void operator+=(const Pt& a) {x += a.x, y += a.y;}
    void operator-=(const Pt& a) {x -= a.x, y -= a.y;}
    long long int operator*(const Pt& a) {return x*a.x + y*a.y;}
    long long int operator/(const Pt& a) {return x*a.y - y*a.x;}
    
    operator long long int() const { // Returns the squared euclidean distance.
        return x*x+y*y;
    }
    
    bool operator>(const Pt& a) {return (long long int)(*this) > (long long int)(a);}
    bool operator<(const Pt& a) {return (long long int)(*this) < (long long int)(a);}
    bool operator==(const Pt& a) {return (long long int)(*this) == (long long int)(a);}
    bool operator<=(const Pt& a) {return !(*this > a);}
    bool operator>=(const Pt& a) {return !(*this < a);}
    bool operator!=(const Pt& a) {return !(*this == a);}
};

int main() {
    Pt pts[7];
    for (int i = 0; i < 7; i++) {
        long long int x, y;
        cin >> x >> y;
        pts[i].x = x;
        pts[i].y = y;
    }
    
    // p2 p1 p3 acute angle
    //cout << (p3-p1).x << " ";
    if ((p2-p1) * (p3-p1) <= 0) {
        cout << "N";
        return 0;
    }
    // p1p2 == p1p3
    if ((p2-p1) != (p3-p1)) {
        cout << "N";
        return 0;
    }
    // p2 p3 p4 p5 colinear
    if ((p2-p3)/(p4-p3) != 0) abort
    if ((p2-p5)/(p4-p5) != 0) abort
    
    // p2p3 p4p5 mid points are the same
    if (p2*2+(p3-p2) != p4*2+(p5-p4)) abort
    
    // p2p3 bigger than p4p5
    if (p3-p2 <= p5-p4) abort
    
    // p4p5 p6p7 perpendicular to p2p3
    if ((p6-p4)*(p3-p4) != 0) abort
    if ((p7-p5)*(p3-p5) != 0) abort
    
    // p4p6 p5p7 congruent
    if ((p4-p6) != (p5-p7)) abort
    
    // p1p6 intersects only in a single point with p2p3
    if ((p1-p2)/(p3-p2) >= 0 && (p6-p2)/(p3-p2) >= 0) abort
    if ((p1-p2)/(p3-p2) <= 0 && (p6-p2)/(p3-p2) <= 0) abort
    
    cout << "S";
    return 0;
}