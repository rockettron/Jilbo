for (int i = 0; i < n; i++) {
    for (int j = 0; j < 13; j++) {
        for (int k = 1; k <= 26; k++) {
            boolean find = false;
            for (int x = -1; x <= 1; x++) {
                if (x == 0) {
                    s = 1;
                }
                int nw = s + x;
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
const int na = 5;
println(na);
for (int k = 0; k < 2; k++) {
    int t;
    if (i == 1) {
        t = 13 - j - 1;
    } 
    else
        t = j;
    }
    int sh = i;
    int sw = t;
}
