class QuadTreeNode
{
    boolean end = true;
    /**
     * ZYX
     * [0] BBB
     * [1] BBA
     * [2] BAB
     * [3] BAA
     * [4] ABB
     * [5] ABA
     * [6] AAB
     * [7] AAA
     */
    QuadTreeNode nodes[] = new QuadTreeNode[4];
    
    public QuadTreeNode(int size)
    {
        if (size == 1)
        {
            return;
        }
        //size /= 2;
        size >>= 0x1;
        nodes[0] = new QuadTreeNode(size);
        nodes[1] = new QuadTreeNode(size);
        nodes[2] = new QuadTreeNode(size);
        nodes[3] = new QuadTreeNode(size);
//        nodes[4] = new QuadTreeNode(size);
//        nodes[5] = new QuadTreeNode(size);
//        nodes[6] = new QuadTreeNode(size);
//        nodes[7] = new QuadTreeNode(size);
    }
    public QuadTreeNode node(int x, int y, /*int z,*/ int depth)
    {
        QuadTreeNode o = nodes[
            //((z & 0x1) << 0x2) +
            ((y & 0x1) << 0x1) +
            (x & 0x1)
        ];
        if (depth == 0)
        {
            return o;
        }
        return o.node(x >> 0x1, y >> 0x1, /*z >> 0x1,*/ depth - 1);
    }
}

//class QuadTreeEl extends QuadTreeNode
//{
//    ArrayList<Bird> birds = new ArrayList<Bird>();
//}

class QuadTree
{
    private QuadTreeNode qn;
    private int depth;
    public QuadTree(int size)
    {
        qn = new QuadTreeNode(size);
        depth = (int)(log(size)/log(2));
    }
    public void insert(int x, int y)
    {
        qn.node(x, y, depth);
    }
    // 
}

class Bird
{
    int x, y;
    int dirX, dirY;
    public Bird()
    {
        x = (int)random(screenW);
        y = (int)random(screenH);
        dirX = (int)random(5);
        dirY = (int)random(5);
    }
    public void update()
    {
        x += dirX;
        x %= screenW;
        y += dirY;
        y %= screenH;
    }
    public void draw()
    {
        point(x, y);
    }
}

QuadTree o;
ArrayList<Bird> birds = new ArrayList<Bird>();
int birdsCount = 1000;
int screenW = 1024;
int screenH = 768;



void setup()
{
    o = new QuadTree(256);
    for (int i = 0; i < birdsCount; ++i)
    {
        birds.add(new Bird());
    }
    
    size(screenW, screenH);
    frameRate(60);
}

void draw()
{
    background(0);
    stroke(255, 255, 255);
    for (int i = 0; i < birdsCount; ++i)
    {
        birds.get(i).update();
        birds.get(i).draw();
    }
}

