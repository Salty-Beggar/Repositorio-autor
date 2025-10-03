import java.io.*;
import java.util.*;

class AlmostSmallestPath {
    public static void main(String[] args) throws IOException {
        BufferedReader b = new BufferedReader(new InputStreamReader(System.in));
        String[] curLine = b.readLine().split(" ");
        int N = Integer.parseInt(curLine[0]);
        int M = Integer.parseInt(curLine[1]);
        curLine = b.readLine().split(" ");
        int src = Integer.parseInt(curLine[0]);
        int dest = Integer.parseInt(curLine[1]);
        
        ArrayList<ArrayList<Integer[]>> adjList = new ArrayList<>();
        for (int i = 0; i < N; i++) adjList.add(new ArrayList<>());
        
        for (int i = 0; i < M; i++) {
            curLine = b.readLine().split(" ");
            int u = Integer.parseInt(curLine[0]);
            int v = Integer.parseInt(curLine[1]);
            int weight = Integer.parseInt(curLine[2]);
            adjList.get(u).add(new Integer[]{v, weight});
        }
        
        System.out.println(AlmostSmallestPath.findAlmostSmallestPath(N, adjList, src, dest));
    }
    
    public static int findAlmostSmallestPath(int n, ArrayList<ArrayList<Integer[]>> adjList, int src, int dest) {
        int[] curNodeWeights = new int[n];
        ArrayList<ArrayList<Integer>> curNodeNexts = new ArrayList<>();
        ArrayList<ArrayList<Integer[]>> curNodePrevs = new ArrayList<>();
        for (int i = 0; i < n; i++) {
            curNodeWeights[i] = Integer.MAX_VALUE;
            curNodeNexts.add(new ArrayList<>());
            curNodePrevs.add(new ArrayList<>());
        }
        curNodeWeights[src] = 0;
        PriorityQueue<Integer> nodePQueue = new PriorityQueue<>(Comparator.comparingInt(a -> curNodeWeights[a]));
        nodePQueue.add(src);
        
        while (!nodePQueue.isEmpty()) {
            int curNode = nodePQueue.poll();
            int curNodeWeight = curNodeWeights[curNode];
            for (int i = 0; i < adjList.get(curNode).size(); i++) {
                Integer[] curNeighbour = adjList.get(curNode).get(i);
                int curNeighbourNode = curNeighbour[0];
                int curNeighbourWeight = curNeighbour[1];
                if (curNodeWeights[curNeighbourNode] > curNodeWeight+curNeighbourWeight) {
                    curNodeWeights[curNeighbourNode] = curNodeWeight+curNeighbourWeight;
                    
                    curNodePrevs.get(curNeighbourNode).clear();
                    curNodePrevs.get(curNeighbourNode).add(new Integer[]{curNode, i});
                    
                    //if (curNode == 0) System.out.println(String.format("%d %d", curNode, i));
                    if (curNeighbourNode != dest) nodePQueue.add(curNeighbourNode);
                }else if (curNodeWeights[curNeighbourNode] == curNodeWeight+curNeighbourWeight) {
                    curNodePrevs.get(curNeighbourNode).add(new Integer[]{curNode, i});
                }
            }
        }
        
        //System.out.println(curNodeNexts.get(0).get(0));
        
        Stack<Integer> curNodePointerStack = new Stack<>();
        curNodePointerStack.push(dest);
        while (!curNodePointerStack.isEmpty()) {
            int curNode = curNodePointerStack.pop();
            /*for (int curNext : curNodeNexts.get(curNode)) {
                adjList.get(curNode).set(curNext, null);
                System.out.println(String.format("%d %d", curNode, curNext));
            }*/
            for (Integer[] curPrev : curNodePrevs.get(curNode)) {
                adjList.get(curPrev[0]).set(curPrev[1], null);
                curNodePointerStack.push(curPrev[0]);
            }
        }
        
        for (int i = 0; i < n; i++) {
            curNodeWeights[i] = Integer.MAX_VALUE;
        }
        curNodeWeights[src] = 0;
        nodePQueue.clear();
        nodePQueue.add(src);
        boolean hasReachedDest = false;
        while (!nodePQueue.isEmpty()) {
            int curNode = nodePQueue.poll();
            int curNodeWeight = curNodeWeights[curNode];
            for (int i = 0; i < adjList.get(curNode).size(); i++) {
                Integer[] curNeighbour = adjList.get(curNode).get(i);
                if (curNeighbour == null) continue;
                int curNeighbourNode = curNeighbour[0];
                int curNeighbourWeight = curNeighbour[1];
                if (curNodeWeights[curNeighbourNode] > curNodeWeight+curNeighbourWeight) {
                    curNodeWeights[curNeighbourNode] = curNodeWeight+curNeighbourWeight;
                    if (curNeighbourNode != dest) nodePQueue.add(curNeighbourNode);
                    else hasReachedDest = true;
                }
            }
        }
        
        return (hasReachedDest) ? curNodeWeights[dest] : -1;
    }
}