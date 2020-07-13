//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by Tran Viet Anh on 4/2/18.
//  Copyright © 2018 Tran Viet Anh. All rights reserved.
//


// So sanh ip table
// Xem source shadowsocks vpn

#import "PacketTunnelProvider.h"

#import <NetworkExtension/NETunnelProvider.h>
#import "OpenVPNAdapter.h"
#import "OpenVPNReachability.h"
#import "OpenVPNConfiguration.h"
#import "OpenVPNProperties.h"
#import "OpenVPNCredentials.h"
#import "OpenVPNAdapterEvent.h"
#import "OpenVPNTransportProtocol.h"
#import "OpenVPNError.h"
@implementation PacketTunnelProvider{
    NWUDPSession *_UDPSession;
    NWTCPConnection *_TCPConnection;
    
    dispatch_queue_t _dispatchQueue;
    NSMutableArray *_outgoingBuffer;
    NSDictionary *config;
    OpenVPNAdapter *vpnAdapter;
    OpenVPNReachability *vpnReachability;
    OpenVPNConfiguration *configuration;
    OpenVPNProperties *properties;
}

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    config = [[NSDictionary alloc] init];
    NETunnelProviderProtocol *protocol = (NETunnelProviderProtocol *)self.protocolConfiguration;
    config = protocol.providerConfiguration;
    
    // add port, add to config
    
    vpnAdapter = [[OpenVPNAdapter alloc] init];
    vpnAdapter.delegate = self;
    
    vpnReachability = [[OpenVPNReachability alloc] init];
    NSString *content = config[@"content"];
    // add to content
    
    
   
    
    // Load config data
    NSString *username = config[@"username"];
    NSString *password = config[@"password"];
//    NSString *server = config[@"server"];
//    NSString *pro = config[@"pro"];
//    NSString *port = config[@"port"];
//
//    content = [content stringByReplacingOccurrencesOfString:@"<ip_server>" withString:server];
//    content = [content stringByReplacingOccurrencesOfString:@"<port>" withString:port];
//    content = [content stringByReplacingOccurrencesOfString:@"<protocol>" withString:pro];
    
    configuration = [[OpenVPNConfiguration alloc] init];
       configuration.fileContent = [content dataUsingEncoding:NSUTF8StringEncoding];
       properties = [vpnAdapter applyConfiguration:configuration error:nil];
    
    OpenVPNCredentials *credentials = [[OpenVPNCredentials alloc] init];
    
    credentials.username = username;
    credentials.password = password;
    
    [vpnAdapter provideCredentials:credentials error:nil];
    [vpnAdapter connect];
    return;
}

- (void) setupUDPSession: (NEPacketTunnelNetworkSettings *) setting{
    self.reasserting = false;
    NSString *_serverAddress = properties.remoteHost;
    NSString *_port = [@(properties.remotePort) stringValue];
    if(properties.remoteProto == OpenVPNTransportProtocolUDP){
        // Open UDP Session
        if(_UDPSession != nil){
            self.reasserting = true;
            _UDPSession = nil;
        }
        
        [self setTunnelNetworkSettings:nil completionHandler:^(NSError * _Nullable error){
            if(error != nil){
                NSLog(@"Error set TunnelNetwork %@", error);
            }
            _UDPSession = [self createUDPSessionToEndpoint:[NWHostEndpoint endpointWithHostname:_serverAddress port:_port] fromEndpoint:nil];
            [self setTunnelNetworkSettings:setting completionHandler:^(NSError * _Nullable error){
                if(error != nil){
                    NSLog(@"%@", error);
                }
            }];
        }];
    }else{
        // Open TCP Session
        if(_TCPConnection != nil){
            self.reasserting = true;
            _TCPConnection = nil;
        }
        
        [self setTunnelNetworkSettings:nil completionHandler:^(NSError * _Nullable error){
            if(error != nil){
                NSLog(@"Error set TunnelNetwork %@", error);
            }
            // = [self createUDPSessionToEndpoint:[NWHostEndpoint endpointWithHostname:_serverAddress port:_port] fromEndpoint:nil];
            _TCPConnection = [self createTCPConnectionToEndpoint:[NWHostEndpoint endpointWithHostname:_serverAddress port:_port] enableTLS:false TLSParameters:nil delegate:self];
            [self setTunnelNetworkSettings:setting completionHandler:^(NSError * _Nullable error){
                if(error != nil){
                    NSLog(@"%@", error);
                }
            }];
        }];
    }
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    // Add code here to start the process of stopping the tunnel.
    completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
    // Add code here to handle the message.
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
    // Add code here to get ready to sleep.
    completionHandler();
}

- (void)wake {
}

// OpenVPNAdapter calls this delegate method to configure a VPN tunnel.
- (void)openVPNAdapter:(nonnull OpenVPNAdapter *)openVPNAdapter configureTunnelWithNetworkSettings:(NEPacketTunnelNetworkSettings *)networkSettings completionHandler:(nonnull void (^)(id<OpenVPNAdapterPacketFlow> _Nullable))completionHandler {
    [self setupUDPSession:networkSettings];
    completionHandler(self.packetFlow);
}

// Handle errors thrown by the OpenVPN3
- (void)openVPNAdapter:(nonnull OpenVPNAdapter *)openVPNAdapter handleError:(nonnull NSError *)error {
    NSDictionary *userInfo = [error userInfo];
    NSString *errorString = [userInfo objectForKey:OpenVPNAdapterErrorMessageKey];
    NSLog(@"In here");
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.co.oliver.vpn"];
    [myDefaults setObject:errorString forKey:@"auth"];
}

// Process events returned by the core OpenVPN3
- (void)openVPNAdapter:(nonnull OpenVPNAdapter *)openVPNAdapter handleEvent:(OpenVPNAdapterEvent)event message:(nullable NSString *)message {
    switch (event) {
        case OpenVPNAdapterEventConnected:
        {
            NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                          initWithSuiteName:@"group.co.oliver.vpn"];
            [myDefaults setObject:@"COMPLETE" forKey:@"auth"];
            break;
        }
        case OpenVPNAdapterEventDisconnected:
            break;
        case OpenVPNAdapterEventReconnecting:
            break;
        case OpenVPNAdapterEventResolve:
            break;
        case OpenVPNAdapterEventWaitProxy:
            break;
        case OpenVPNAdapterEventConnecting:
            break;
        case OpenVPNAdapterEventGetConfig:
            break;
        case OpenVPNAdapterEventAssignIP:
            break;
        case OpenVPNAdapterEventAddRoutes:
            break;
        case OpenVPNAdapterEventEcho:
            break;
        case OpenVPNAdapterEventInfo:
            break;
        case OpenVPNAdapterEventPause:
            break;
        case OpenVPNAdapterEventResume:
            break;
        case OpenVPNAdapterEventRelay:
            break;
        case OpenVPNAdapterEventUnknown:
            break;
        default:
            break;
    }
}

@end


