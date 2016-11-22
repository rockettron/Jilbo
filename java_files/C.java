import java.util.Arrays;
import java.util.Scanner;

public class C {
    Scanner sc = new Scanner(System.in);

    void run() {
        char[] s = sc.next().toCharArray();
        int n = s.length;
        for (int i = 0; i < n - 1; i++) {
            if (s[i] == s[i + 1]) {
                System.out.println("Impossible");
                return;
            }
        }

        char[][] f = new char[2][13];
        int[] o = new int[26];
        char d = 'd';
        for (int i = 0; i < n; i++) o[s[i] - 'A']++;
        for (int i = 0; i < n; i++) if (o[s[i] - 'A'] == 2) d = s[i];
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 13; j++) {
                for (int k = 0; k < 2; k++) Arrays.fill(f[k], '.');
                int t = (i == 1) ? 13 - j - 1 : j;
                f[i][t] = s[0];
                boolean dd = false;
                int h = i;
                int w = t;
                for (int k = 0; k <= 26; k++) {
                    if (s[k] == d && dd) continue;
                    if (s[k] == d) dd = true;
                    f[h][w] = s[k];
                    if (h == 0 && w == 12) h++;
                    else if (h == 1 && w == 0) h--;
                    else if (h == 0) w++;
                    else if (h == 1) w--;
                }
                int sh = i;
                int sw = t;
                for (int k = 1; k <= 26; k++) {
                    boolean find = false;
                    L: for (int x = -1; x <= 1; x++) {
                        for (int y = -1; y <= 1; y++) {
                            if (x == 0 && y == 0) continue;
                            int nh = sh + y;
                            int nw = sw + x;
                            if (inner(nh, nw, 2, 13)) {
                                if (f[nh][nw] == s[k]) {
                                    find = true;
                                    if (k == 26) {
                                        out(f);
                                        return;
                                    }
                                    sh = nh;
                                    sw = nw;
                                    break L;
                                }
                            }
                        }
                    }
                    if (!find) break;
                }
            }
        }
        System.out.println("Impossible");
    }

    public static void main(String[] args) {
        new C().run();
    }

    void out(char[][] array) {
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[i].length; j++) System.out.print(array[i][j]);
            System.out.println();
        }
    }

    boolean inner(int h, int w, int limH, int limW) {
        return 0 <= h && h < limH && 0 <= w && w < limW;
    }
}
