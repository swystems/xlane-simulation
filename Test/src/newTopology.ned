//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package test2;

import ned.DatarateChannel;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;


import ned.DatarateChannel;




module NewHosts
{
    parameters: 
        int replicas;
        int clients;
        bool coord;
        
    gates:
        inout hosts[int((k^3)/4)];
       
    submodules:
        client[clients]: StandardHost;
        
        clientSwitch: Router {
            multicastForwarding = true;
        }
        
        coordinator[coord]: StandardHost;

        replica[replicas]: StandardHost;
    connections:
        clientSwitch.ethg++ <--> SwitchToSwitch <--> hosts[0];
        
        for i=0..sizeof(client)-1 {
            clientSwitch.ethg++ <--> HostToSwitch <--> client[i].ethg++;
        }
        
//        coordinator.ethg++ <--> HostToSwitch  <--> hosts[1];
        
        for i=0..sizeof(replica)-1 {
            replica[i].ethg++ <--> HostToSwitch <--> hosts[i+2];
        }
            
    
}



network NewTopology
{
     parameters:
        int replicas;
        int clients;
        bool coord;

    submodules:
        coreSwitch[int((k/2)^2)]: Router {
            multicastForwarding = true;
        }
        pod[k]: Pod2 {
            k = k;
        }
		hosts: NewHosts {
		    replicas = replicas;
		    clients = clients;
		    coord = coord;
		}
        configurator: Ipv4NetworkConfigurator;

    connections:
        
        for i=0..sizeof(pod)-1, for j=0..sizeof(coreSwitch)-1 {
            pod[i].port++ <--> SwitchToSwitch <--> coreSwitch[j].ethg++;
        }
        
        for i=0..sizeof(pod)-1, for j=0..int((k/2)^2)-1 {
            hosts.hosts++ <--> pod[i].hosts++;
        }
}
