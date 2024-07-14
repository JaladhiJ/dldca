#include "cache.h"
#include "msl/lru_table.h"
#include <algorithm>
#include <array>
#include <map>
#include <optional>
#include<bits/stdc++.h>
using namespace std;
namespace
{
struct tracker{
    std::array<std::array<uint64_t, 2>, 64> table = {0};
    std::vector<std::pair<uint64_t, bool>> checkvec;
    int count=-1;
    std::map<uint64_t, uint64_t> last_used_cycles;
    
    int PREFETCH_DEGREE=100;
    int PREFETCH_DISTANCE=10;
};
std::map<CACHE*, tracker> trackers;
}
void CACHE::prefetcher_initialize() {}

uint32_t CACHE::prefetcher_cache_operate(uint64_t addr, uint64_t ip, uint8_t cache_hit, bool useful_prefetch, uint8_t type, uint32_t metadata_in)
{
if(!cache_hit)
{//   uint64_t pf_addr = addr + (1 << LOG2_BLOCK_SIZE);
//   prefetch_line(pf_addr, true, metadata_in);
 //for(int i=0;i<5;i++){cout<<trackers[this].table[i][0]<<endl;}
  bool tab=false;
  for(int i=0;i<64;i++)
  {
    if(::trackers[this].table[i][0]< ::trackers[this].table[i][1])//startaddr<endaddr
    {
      
        if(addr>=::trackers[this].table[i][0] && addr<=::trackers[this].table[i][1])
        {
          //cout<<"atom"<<endl;
            //prefetch karna hai found in monitoring region
            //STREAM direction is  1 here
            for(int j=1;j<=::trackers[this].PREFETCH_DEGREE;j++)
            {
              uint64_t pf_addr = ::trackers[this].table[i][1] + (j << LOG2_BLOCK_SIZE);//start address +....
             // cout<<pf_addr<<endl;
              prefetch_line(pf_addr, true, 1);
            }
            ::trackers[this].table[i][0]=::trackers[this].table[i][0]+::trackers[this].PREFETCH_DEGREE;
            ::trackers[this].table[i][1]=::trackers[this].table[i][1]+::trackers[this].PREFETCH_DEGREE;
            ::trackers[this].last_used_cycles[i]=current_cycle;;
            tab=true;
            return metadata_in;
        }
        //cout<<trackers[this].table[i][0]<<" " <<trackers[this].table[i][1]<<endl;
    }
    
    else if(::trackers[this].table[i][0]> ::trackers[this].table[i][1])//endaddr<startendr
    {
      
      if(addr<=::trackers[this].table[i][0]&& addr>=::trackers[this].table[i][1])
        {
            //prefetch karna hai aur break karna hai
            //stream direction is 0 here
            //cout<<"bhen"<<endl;
             for(int j=1;j<=::trackers[this].PREFETCH_DEGREE;j++)
            {
              uint64_t pf_addr = ::trackers[this].table[i][1] - (j << LOG2_BLOCK_SIZE);//start address +....
              prefetch_line(pf_addr, true, 1);
            }
            ::trackers[this].table[i][0]=::trackers[this].table[i][0]-::trackers[this].PREFETCH_DEGREE;
            ::trackers[this].table[i][1]=::trackers[this].table[i][1]-::trackers[this].PREFETCH_DEGREE;
            ::trackers[this].last_used_cycles[i]=current_cycle;;
            tab=true;
            return metadata_in;
        }
    }
  }
 bool triplet=false;
 if(tab==false)
 {
  //cout<<"c"<<endl;
    //checkvec.push_back(addr,false);
    ::trackers[this].checkvec.push_back(std::make_pair(addr, false));
    ::trackers[this].count++;
    uint64_t start_addr;
    uint64_t end_addr;
    if(::trackers[this].count>=2)
    {
       if(::trackers[this].checkvec[::trackers[this].count-1].second==false && ::trackers[this].checkvec[::trackers[this].count-2].second==false)//pichle dono false hai to hi possibility hai triplet banne ki
       {
        //cout<<"d"<<endl;

          if(::trackers[this].checkvec[::trackers[this].count-1].first>=::trackers[this].checkvec[::trackers[this].count-2].first)//streamdirection1 hai
          {
              if(::trackers[this].checkvec[::trackers[this].count].first>=::trackers[this].checkvec[::trackers[this].count-1].first && ::trackers[this].checkvec[::trackers[this].count].first>=::trackers[this].checkvec[::trackers[this].count-2].first && ::trackers[this].checkvec[::trackers[this].count].first-::trackers[this].checkvec[::trackers[this].count-2].first<((::trackers[this].PREFETCH_DISTANCE)<< LOG2_BLOCK_SIZE))//,atlab triplet 
              //yahan wo z<prefetch distance vaala bhi chutiyap hai i am hoping yahin daalna kyunki iske alava checkvec[count]ki gaand to nahi maari
              {
                //cout<<"here"<<endl;

                 triplet=true;
                 ::trackers[this].checkvec[::trackers[this].count].second=true;
                 ::trackers[this].checkvec[::trackers[this].count-1].second=true;//jiska triplet banchuka wo true baki false
                 ::trackers[this].checkvec[::trackers[this].count-2].second=true;
                 start_addr=::trackers[this].checkvec[::trackers[this].count-2].first;
                 end_addr=start_addr+((::trackers[this].PREFETCH_DISTANCE)<< LOG2_BLOCK_SIZE);
              }
          }
          else if(::trackers[this].checkvec[::trackers[this].count-1].first<=::trackers[this].checkvec[::trackers[this].count-2].first)//streamdirection-1 hai//X>=Y HAI BKL PRINT HO RAHA HAI EO NAHI BCX>X-Y>X-Z
          {
            //cout<<"bkl"<<endl;
              if(::trackers[this].checkvec[::trackers[this].count].first<=::trackers[this].checkvec[::trackers[this].count-1].first && ::trackers[this].checkvec[::trackers[this].count].first<=::trackers[this].checkvec[::trackers[this].count-2].first && ((::trackers[this].checkvec[::trackers[this].count-2].first)-(::trackers[this].checkvec[::trackers[this].count].first))<(::trackers[this].PREFETCH_DISTANCE)<< LOG2_BLOCK_SIZE)//,atlab triplet mila
              {
                //cout<<"eo"<<endl;
                triplet=true;
                 ::trackers[this].checkvec[::trackers[this].count].second=true;
                 ::trackers[this].checkvec[::trackers[this].count-1].second=true;//jiska triplet banchuka wo true baki false
                 ::trackers[this].checkvec[::trackers[this].count-2].second=true;
                 start_addr=::trackers[this].checkvec[::trackers[this].count-2].first;
                 end_addr=start_addr-((::trackers[this].PREFETCH_DISTANCE)<< LOG2_BLOCK_SIZE);
              }
          }
       }  
    }
    if(triplet==true)
    {
      //cout<<"f"<<endl;
      bool full=true;
      for(int k=0;k<64;k++)
      {
          if(::trackers[this].table[k][0]==0&& ::trackers[this].table[k][1]==0)//initialise
          {
            //cout<<"notf"<<endl;
            full=false;
            ::trackers[this].table[k][0]=start_addr;
            ::trackers[this].table[k][1]=end_addr;
            ::trackers[this].last_used_cycles[k]=current_cycle;
            return metadata_in;//od dete hai insert karne ke baad
          }
      }
      //iftable full to lru vaali cheez
      if(full==true)
      {
        //cout<<"g"<<endl;
          uint64_t mi = 0;
          uint64_t minValue = std::numeric_limits<uint64_t>::max();

          for (const auto& pair : ::trackers[this].last_used_cycles)
          {
              if (pair.second < minValue)
              {
                 //cout<<"aata"<<endl;
                  minValue = pair.second;
                  mi = pair.first;
              }
          }
          ::trackers[this].table[mi][0]=start_addr;
          ::trackers[this].table[mi][1]=end_addr;   
          ::trackers[this].last_used_cycles[mi]=current_cycle;
          return metadata_in;//od do
      }
    }
    //monitoring region dhundhna hai
 }}
  return metadata_in;
}

uint32_t CACHE::prefetcher_cache_fill(uint64_t addr, uint32_t set, uint32_t way, uint8_t prefetch, uint64_t evicted_addr, uint32_t metadata_in)
{
  return metadata_in;
}

void CACHE::prefetcher_cycle_operate(){}

void CACHE::prefetcher_final_stats(){}
