
import java.io.*;
import java.util.*;

public class CompanyQueries {
	public static void main(String[] args) throws IOException {
		BufferedReader b = new BufferedReader(new InputStreamReader(System.in));
		
		String[] curLine = b.readLine().split(" ");
		int n = Integer.parseInt(curLine[0]);
		int q = Integer.parseInt(curLine[1]);
		
		curLine = b.readLine().split(" ");
		int[] bosses = new int[n];
		for (int i = 1; i < n; i++) {
			bosses[i] = Integer.parseInt(curLine[i-1])-1;
		}
		
		int[][] queries = new int[q][2];
		for (int i = 0; i < q; i++) {
			curLine = b.readLine().split(" ");
			queries[i][0] = Integer.parseInt(curLine[0])-1;
			queries[i][1] = Integer.parseInt(curLine[1]);
		}
		solve(n, bosses, q, queries);
	}
	
	public static void solve(int n, int[] bosses, int q, int[][] queries) {
		int maxLeaps = 1<<17;
		int[][] bossBinaryLeap = new int[n][maxLeaps];
		
		bossBinaryLeap[0][0] = -1;
		for (int i = 1; i < n; i++) bossBinaryLeap[i][0] = bosses[i];
		for (int i = 1; i < maxLeaps; i++) {
			for (int j = 0; j < n; j++) {
				if (bossBinaryLeap[j][i-1] == -1)
					bossBinaryLeap[j][i] = -1;
				else
					bossBinaryLeap[j][i] = bossBinaryLeap[bossBinaryLeap[j][i-1]][i-1];
			}
		}
		
		for (int i = 0; i < q; i++) {
			int[] curQuery = queries[i];
			int curBoss = curQuery[0];
			for (int j = 0; j < 17; j++) {
				int cBit = 1<<j;
				if ((curQuery[1] & cBit) == cBit) {
			        //System.out.println(String.format("Hello: %d %d", curQuery[1], curBoss));
					if (bossBinaryLeap[curBoss][j] == -1) {
						curBoss = -1;
						break;
					}else
						curBoss = bossBinaryLeap[curBoss][j];
				}
			}
			System.out.println((curBoss == -1) ? -1 : curBoss+1);
		}
	}
}
