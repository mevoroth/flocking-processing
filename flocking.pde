public class Vector2
{
    public float x, y;
    
    public Vector2(float x, float y)
    {
        this.x = x;
        this.y = y;
    }
    public Vector2 normalize()
    {
        float d = dist();
        x /= d;
        y /= d;
        return this;
    }
    public void mult(float m)
    {
        x *= m;
        y *= m;
    }
    public float dist()
    {
        return sqrt(sqDist());
    }
    public float sqDist()
    {
        return x*x + y*y;
    }
    public Vector2 sub(Vector2 a)
    {
        return new Vector2(x - a.x, y - a.y);
    }
    public void addTo(Vector2 a)
    {
        x += a.x;
        y += a.y;
    }
    public void zero()
    {
        x = 0;
        y = 0;
    }
}

void Physics(Bird b)
{
    for (int i = 0; i < cylindersCount; ++i)
    {
        Vector2 p = b.p.sub(cylinders.get(i));
        if (p.sqDist() < CYLINDER)
        {
           p = new Vector2(-p.x, -p.y);
           b.p = b.p.sub(p.normalize());
           b.v = p.normalize();
        }
    }
}

public class Bird
{
    public Vector2
        p,   // Position
        v,   // Velocity
        r,   // Repulsion
        a,   // Attraction
        d,   // Direction
        w,   // Walls
        c    // Custom
    ;
    
    public Bird()
    {
        p = new Vector2(random(screenW), random(screenH));
        v = new Vector2(random(INIT_SPEED*2.0) - INIT_SPEED, random(INIT_SPEED*2.0) - INIT_SPEED);
        r = new Vector2(0, 0);
        a = new Vector2(0, 0);
        d = new Vector2(random(INIT_SPEED*2.0) - INIT_SPEED, random(INIT_SPEED*2.0) - INIT_SPEED);
        w = new Vector2(0, 0);
        c = new Vector2(0, 0);
    }
    public void update()
    {
        repulsion();
        direction();
        attraction();
        
        v.x = (r.x + a.x + d.x + c.x);
        v.y = (r.y + a.y + d.y + c.y);
        //v.normalize();
        v.mult(5);
        
        p.x += v.x + screenW;
        p.x %= screenW;
        p.y += v.y + screenH;
        p.y %= screenH;
        
        Physics(this);
        
        r.zero();
        a.zero();
        d.zero();
        w.zero();
        c.zero();
    }
    
    public void repulsion()
    {
        float rC = 0;
        for (int i = 0; i < birdsCount; ++i)
        {
            if (this == birds.get(i))
            {
                continue;
            }
            Vector2 diff = p.sub(birds.get(i).p);
            if (diff.sqDist() < REPULSION)
            {
                float dist = diff.dist();
                diff.normalize();
                diff.mult(1/dist);
                r.addTo(diff);
                ++rC;
            }
        }
        if (rC > 0)
        {
            r.mult(1.0/rC);
            r.normalize();
        }
    }
    
    public void attraction()
    {
        float aC = 0;
        for (int i = 0; i < birdsCount; ++i)
        {
            if (this == birds.get(i))
            {
                continue;
            }
            Vector2 diff = birds.get(i).p.sub(p);
            if (diff.sqDist() < ATTRACTION)
            {
                a.addTo(birds.get(i).p);
                ++aC;
            }
        }
        if (aC > 0)
        {
            a.mult(1.0/aC);
            a = a.sub(p);
            a.normalize();
        }
    }
    
    public void direction()
    {
        float dC = 0;
        for (int i = 0; i < birdsCount; ++i)
        {
            if (this == birds.get(i))
            {
                continue;
            }
            Vector2 diff = birds.get(i).p.sub(p);
            if (diff.sqDist() < DIRECTION)
            {
                d.addTo(birds.get(i).v);
                ++dC;
            }
        }
        if (dC > 0)
        {
            d.mult(1.0/dC);
            d.normalize();
        }
    }
    
//    public void avoidance()
//    {
//        float aC = 0;
//        for (int i = 0; i < cylindersCount; ++i)
//        {
//            Vector2 diff = cylinders.get(i).sub(p);
//            if (diff.sqDist() < CYLINDER)
//            {
//                w.addTo(diff.normalize());
//                ++aC;
//            }
//        }
//        
//        if (aC > 0)
//        {
//            w.mult(1.0/aC);
//            w.normalize();
//        }
//    }
    
    public void draw()
    {
        //println("Pos : " + p.x + ":" + p.y);
        point(p.x, p.y);
    }
}

ArrayList<Vector2> cylinders = new ArrayList<Vector2>();
int cylindersCount = 1;
ArrayList<Bird> birds = new ArrayList<Bird>();
int birdsCount = 500;
int screenW = 1024;
int screenH = 768;

float INIT_SPEED = 1.0;
float REPULSION = 2500.0; // Square dist
float DIRECTION = 10000.0; // Square dist
float ATTRACTION = 22500.0; // Square dist

float CYLINDER = 10000.0;

void setup()
{
    for (int i = 0; i < birdsCount; ++i)
    {
        birds.add(new Bird());
    }
    
    cylinders.add(new Vector2(512, 384));
    
    size(screenW, screenH);
    frameRate(60);
}

void draw()
{
    background(0);
    stroke(255, 255, 255);
    
    mouseHandler();
    
    for (int i = 0; i < birdsCount; ++i)
    {
        birds.get(i).update();
        birds.get(i).draw();
    }
}

void mouseHandler()
{
    if (mousePressed && mouseButton == LEFT)
    {
        for (int i = 0; i < birdsCount; ++i)
        {
            Vector2 diff = (new Vector2(mouseX, mouseY)).sub(birds.get(i).p);
            float dist = diff.dist();
            diff.normalize();
            diff.mult(1/dist);
            birds.get(i).c = diff.normalize();
        }
    }
    if (mousePressed && mouseButton == RIGHT)
    {
        for (int i = 0; i < birdsCount; ++i)
        {
            Vector2 diff = birds.get(i).p.sub(new Vector2(mouseX, mouseY));
            float dist = diff.dist();
            diff.normalize();
            diff.mult(1/dist);
            birds.get(i).c = diff.normalize();
        }
    }
}

void mouseReleased()
{
    if (mouseButton == LEFT || mouseButton == RIGHT)
    {
        for (int i = 0; i < birdsCount; ++i)
        {
            //birds.get(i).v = new Vector2(random(INIT_SPEED*2.0) - INIT_SPEED, random(INIT_SPEED*2.0) - INIT_SPEED);
            birds.get(i).c = new Vector2(0.0, 0.0);
        }
    }
}

