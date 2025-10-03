import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

public class lanche {
    public static void main(String[] args) throws IOException {
        BufferedReader b = new BufferedReader(new InputStreamReader(System.in));
        
        String[] curLine = b.readLine().split(" ");
        int n = Integer.parseInt(curLine[0]);
        int m = Integer.parseInt(curLine[1]);
        
        int[][] graph = new int[n][n];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (i != j) graph[i][j] = -1;
                else graph[i][j] = 0;
            }
        }
        
        for (int i = 0; i < m; i++) {
            curLine = b.readLine().split(" ");
            int u = Integer.parseInt(curLine[0])-1;
            int v = Integer.parseInt(curLine[1])-1;
            int w = Integer.parseInt(curLine[2]);
            graph[u][v] = w;
            graph[v][u] = w;
        }
        
        System.out.println(lanche.findBiggestDistance(n, graph));
    }
    
    public static int findBiggestDistance(int n, int[][] graph) {
        int[] nodeBiggestDist = new int[n];
        for (int k = 0; k < n; k++) {
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < n; j++) {
                    if (graph[i][k] != -1 && graph[k][j] != -1) {
                        graph[i][j] = (graph[i][j] == -1) ? graph[i][k]+graph[k][j] : Math.min(graph[i][j], graph[i][k]+graph[k][j]);
                        if (k == n-1) {
                            nodeBiggestDist[i] = Math.max(nodeBiggestDist[i], graph[i][j]);
                            nodeBiggestDist[j] = Math.max(nodeBiggestDist[j], graph[i][j]);
                        }
                    }
                }
            }
        }
        int smallestDist = -1;
        for (int i = 0; i < n; i++) {
            smallestDist = (smallestDist == -1) ? nodeBiggestDist[i] : Math.min(smallestDist, nodeBiggestDist[i]);
        }
        return smallestDist;
    }
}