int n = next();
int p = next();
int t1 = next();
int t2 = 1;
println(t2);
t1 = t1 + t2;
switch (t2) {
	case: break;
}
for (int i = 0; i < n; i++) {
    for (int j = 0; j < 13; j++) {
        for (int k = 1; k <= 26; k++) {
            boolean find;
            find = false;
            for (int x = -1; x <= 1; x++) {
                if (x == 0) {
                    s = 1;
                }
                int nw;
                nw = s + x;
                if (nw == 13) {
                    if (f[nw] == s[k]) {
                        find = true;
                        if (k == 26) {
                            println(f);
                            return;
                        }
                        s = nw;
                    }
                }
            }
            if (!find) break;
        }
    }
}
int k1;
println(k1);
int na = 5;
println(na);
for (int k = 0; k < 2; k++) {
    int t;
    if (i == 1) {
        t = 13 - j - 1;
    } 
    else {
        t = j;
    }
    int sh;
    int sw;
    sh = i;
    sw = t;
    println(i, sh, sw);
}
