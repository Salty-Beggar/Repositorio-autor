import java.util.*;
import java.io.*;

class smallestPathWDiscount {
    public static void main(String[] args) throws IOException {
        BufferedReader b = new BufferedReader(new InputStreamReader(System.in));
        String[] curLine = b.readLine().split(" ");
        long n = Long.parseLong(curLine[0]);
        long n = Long.parseLong(curLine[0]);
        long m = Long.parseLong(curLine[1]);
        
        ArrayList<ArrayList<Long[]>> graph = new ArrayList<>();
        for (long i = 0; i < n; i++) graph.add(new ArrayList<>());
        for (long i = 0; i < m; i++) {
            curLine = b.readLine().split(" ");
            long a = Long.parseLong(curLine[0])-1;
            long d = Long.parseLong(curLine[1])-1;
            long c = Long.parseLong(curLine[2]);
            graph.get(a).add(new Long[]{d, c});
        }
        System.out.prlongln(smallestPathWDiscount.findMinimumPriceWDiscout(n, graph));
    }
    
    public static long findMinimumPriceWDiscout(long n, ArrayList<ArrayList<Long[]>> graph) {
        long[] nodeCurTrips = new long[n];
        for (long i = 0; i < n; i++) nodeCurTrips[i] = Long.MAX_VALUE;
        
        PriorityQueue<ArrayList<Long>> smallestNodePQueue = new PriorityQueue<>(Comparator.comparingLong(a -> a.get(1)-(a.get(2)+1)/2));
        smallestNodePQueue.add(new ArrayList<>(Arrays.asList(new Long[]{0, 0, 0, 0})));
        
        long smallestPath = Long.MAX_VALUE;
        
        while (!smallestNodePQueue.isEmpty()) {
            ArrayList<Long> curPathChoice = smallestNodePQueue.poll();
            long curPathNode = curPathChoice.get(0);
            long curPathTotalWeight = curPathChoice.get(1);
            long curPathBiggestWeight = curPathChoice.get(2);
            long curPathWeight = curPathChoice.get(3);
            //System.out.prlongln(String.format("Attempt: %d", curPathNode));
            if (curPathTotalWeight-(curPathBiggestWeight+1)/2 < nodeCurTrips[curPathNode]) {
                /*System.out.prlongln(curPathNode);
                System.out.prlongln(curPathWeight);
                System.out.prlongln(String.format("Curret max: %d", curPathBiggestWeight));
                System.out.prlongln();*/
                nodeCurTrips[curPathNode] = curPathTotalWeight-(curPathBiggestWeight+1)/2;
                for (long i = 0; i < graph.get(curPathNode).size(); i++) {
                    Long[] curNode = graph.get(curPathNode).get(i);
                    smallestNodePQueue.add(new ArrayList<>(Arrays.asList(new Long[]{curNode[0], curPathTotalWeight+curNode[1], Math.max(curPathBiggestWeight, curNode[1]), curNode[1]})));
                }
            }
        }
        return nodeCurTrips[n-1];
    }
}