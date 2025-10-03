import java.io.*;
import java.util.*;

public class ShortestRoutes2
{
	public static void main(String[] args) throws IOException {
		BufferedReader b = new BufferedReader(new InputStreamReader(System.in));
		
		String[] curLine = b.readLine().split(" ");
		int n = Integer.parseInt(curLine[0]);
		int m = Integer.parseInt(curLine[1]);
		int q = Integer.parseInt(curLine[2]);
		
		int[][] graph = new int[n][n];
		for (int i = 0; i < n; i++)
		    for (int j = 0; j < n; j++)
		        graph[i][j] = -1;
		        
		for (int i = 0; i < m; i++) {
    		curLine = b.readLine().split(" ");
    		int u = Integer.parseInt(curLine[0])-1;
    		int v = Integer.parseInt(curLine[1])-1;
    		int w = Integer.parseInt(curLine[2]);
    		graph[u][v] = w;
    		graph[v][u] = w;
		}
		int[][] queries = new int[q][2];
		for (int i = 0; i < q; i++) {
    		curLine = b.readLine().split(" ");
    		int src = Integer.parseInt(curLine[0]);
    		int dest = Integer.parseInt(curLine[1]);
    		queries[i][0] = src-1;
    		queries[i][1] = dest-1;
		}
		int[] solvedQueries = ShortestRoutes2.solveQueries(n, graph, q, queries);
		for (int i = 0; i < q; i++) {
		    System.out.println(solvedQueries[i]);
		}
	}
	
	public static int[] solveQueries(int n, int[][] graph, int q, int[][] queries) {
	    for (int k = 0; k < n; k++) {
	        for (int i = 0; i < n; i++) {
	            if (graph[i][k] != -1) for (int j = 0; j < n; j++) {
	                if (graph[k][j] != -1)
	                    graph[i][j] = (graph[i][j] != -1) ? Math.min(graph[i][j], graph[i][k]+graph[k][j]) : graph[i][k]+graph[k][j];
	            }
	        }
	    }
	    
	    int[] solvedQueries = new int[q];
	    for (int i = 0; i < q; i++) 
	        solvedQueries[i] = graph[ queries[i][0] ][ queries[i][1] ];
	    
	    return solvedQueries;
	}
}