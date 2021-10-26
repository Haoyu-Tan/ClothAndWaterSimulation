//This struct is used for ray-obstaclce intersection.
//It store both if there is a collision, and how far away it is (int terms of distance allong the ray)
class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}


float raySphereIntersectTime(PVector center, float r, PVector l_start, PVector l_dir){
  
  PVector toCircle = PVector.sub(center, l_start);
  
  float a = l_dir.magSq();
  float b = -2*PVector.dot(l_dir, toCircle);
  float c = toCircle.magSq() - (r*r);
  
  float d = b*b - 4*a*c;
  
  if (d >= 0){
    float t = (-b - sqrt(d)) / (2*a);
    if (t >= 0) return t;
    return -1;
  }
  
  return -1;
}

hitInfo raySphereIntersect(PVector center, float radius, PVector ray_start, PVector ray_dir, float max_t){
  hitInfo hit = new hitInfo();
  
  float time = raySphereIntersectTime(center, radius, ray_start, ray_dir);
  if (time > 0 && time <= max_t){
    hit.hit = true;
    hit.t = time;
  }
  
  return hit;
}
