/**
 * Basic Vector2 class
 * 
 * Useless since we got PVector
 * For learning purpose
 */
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

/**
 * Physic pass
 */
void Physics(Bird b)
{
    // Looping all physical objects and repulse entity
    for (int i = 0; i < cylindersCount; ++i)
    {
        Vector2 p = new Vector2(b.p.x, b.p.y);
        p.addTo(b.v);
        p = p.sub(cylinders.get(i));
        if (p.sqDist() < CYLINDER)
        {
            p.normalize().mult(5);
            b.v = p;
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
        c    // Custom
    ;
    
    public Bird()
    {
        p = new Vector2(random(screenW), random(screenH));
        v = new Vector2(random(INIT_SPEED*2.0) - INIT_SPEED, random(INIT_SPEED*2.0) - INIT_SPEED);
        r = new Vector2(0, 0);
        a = new Vector2(0, 0);
        d = new Vector2(random(INIT_SPEED*2.0) - INIT_SPEED, random(INIT_SPEED*2.0) - INIT_SPEED);
        c = new Vector2(0, 0);
    }
    
    /**
     * Update loop
     */
    public void update()
    {
        // Call to force functions
        repulsion();
        direction();
        attraction();
        
        // Create direction of entity
        v.x = (r.x + a.x + d.x + c.x);
        v.y = (r.y + a.y + d.y + c.y);
        //v.normalize();
        v.mult(5);
        
        // Physic pass
        Physics(this);
        
        // Apply forces
        p.x += v.x + screenW;
        p.x %= screenW;
        p.y += v.y + screenH;
        p.y %= screenH;
        
        // Zero all vectors
        r.zero();
        a.zero();
        d.zero();
        c.zero();
    }
    
    /**
     * Repulsion force
     * 
     * Basically we create an opposite force from the centroid of local entities
     */
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
    
    /**
     * Attraction force
     * 
     * Force along the centroid of local entities
     */
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
    
    /**
     * Direction force
     * 
     * Force based on local entities direction
     */
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
    
    public void draw()
    {
        //println("Pos : " + p.x + ":" + p.y);
        point(p.x, p.y);
    }
}

// Cylinders
ArrayList<Vector2> cylinders = new ArrayList<Vector2>();
int cylindersCount = 1;

// Entities
ArrayList<Bird> birds = new ArrayList<Bird>();
int birdsCount = 500;

int screenW = 1024;
int screenH = 768;

float INIT_SPEED = 1.0;
float REPULSION = 2500.0; // Repulsion local area (Square dist)
float DIRECTION = 10000.0; // Direction local area (Square dist)
float ATTRACTION = 22500.0; // Attraction local area (Square dist)

float CYLINDER = 10000.0; // Cylinder area (Square dist)

void setup()
{
    // Init birds
    for (int i = 0; i < birdsCount; ++i)
    {
        birds.add(new Bird());
    }
    
    // Init Cylinders
    cylinders.add(new Vector2(512, 384));
    
    size(screenW, screenH);
    frameRate(60);
}

void draw()
{
    background(0);
    stroke(255, 255, 255);
    
    mouseHandler();
    
    for (int i = 0; i < cylindersCount; ++i)
    {
        noFill();
        ellipse(
            cylinders.get(i).x,
            cylinders.get(i).y,
            200,
            200
        );
    }
    
    // Update loop
    for (int i = 0; i < birdsCount; ++i)
    {
        birds.get(i).update();
        birds.get(i).draw();
    }
}

void mouseHandler()
{
    // Interaction Regroup
    // We use entity custom force
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
    
    // Interaction Repulse
    // We use entity custom force
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
    // Normal Behavior
    // We're resetting custom force
    if (mouseButton == LEFT || mouseButton == RIGHT)
    {
        for (int i = 0; i < birdsCount; ++i)
        {
            //birds.get(i).v = new Vector2(random(INIT_SPEED*2.0) - INIT_SPEED, random(INIT_SPEED*2.0) - INIT_SPEED);
            birds.get(i).c = new Vector2(0.0, 0.0);
        }
    }
}

