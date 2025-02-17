unit UniqueInstanceRaw;

{
  UniqueInstance is a component to allow only a instance by program

  Copyright (C) 2006 Luiz Americo Pereira Camara
  pascalive@bol.com.br

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc;
  
  function InstanceRunning(const Identifier: String; SendParameters: Boolean = False): Boolean;

  function InstanceRunning: Boolean;

implementation

uses
  SimpleIPCWrapper;

const
  BaseServerId = 'tuniqueinstance_';
  Separator = '|';

var
  FIPCServer: TSimpleIPCServer;

function GetFormattedParams: String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to ParamCount do
    Result := Result + ParamStr(i) + Separator;
end;
  
function InstanceRunning(const Identifier: String; SendParameters: Boolean = False): Boolean;

  function GetServerId: String;
  begin
    if Identifier <> '' then
      Result := BaseServerId + Identifier
    else
      Result := BaseServerId + ExtractFileName(ParamStr(0));
  end;
  
var
  Client: TSimpleIPCClient;
  
begin
  Client := TSimpleIPCClient.Create(nil);
  with Client do
  try
    ServerId := GetServerId;
    Result := IsServerRunning(Client);
    if not Result then
    begin
      //It's the first instance. Init the server
      if FIPCServer = nil then
        FIPCServer := TSimpleIPCServer.Create(nil);
      FIPCServer.ServerID := ServerId;
      FIPCServer.Global := True;
      InitServer(FIPCServer);
    end
    else
      // an instance already exists
      if SendParameters then
      begin
        Active := True;
        SendStringMessage(ParamCount, GetFormattedParams);
      end;
  finally
    Free;
  end;
end;

function InstanceRunning: Boolean;
begin
  Result := InstanceRunning('');
end;

finalization
//  if Assigned(FIPCServer) then FIPCServer.Free;

end.

