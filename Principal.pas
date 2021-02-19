unit Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, REST.Types, FMX.Layouts, FMX.ListBox, FMX.Edit,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.WebBrowser,
  FMX.ScrollBox, FMX.Memo, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, System.JSON, FMX.ExtCtrls, FMX.Objects, StrUtils;

type
  TFLetra = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    vart: TEdit;
    Label3: TLabel;
    vmus: TEdit;
    Buscar: TButton;
    Panel2: TPanel;
    Letra: TMemo;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    Image1: TImage;
    procedure BuscarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FLetra: TFLetra;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TFLetra.BuscarClick(Sender: TObject);
var
  RESTClient1: TRESTClient;
  RESTRequest1: TRESTRequest;

  jsob, jsonob: TJSONObject;
  JSValue: TJSONValue;
  JSONArray: TJSONArray;
  JSONArray1: TJSONArray;
  jPar: TJSONPair;

  i: integer;

  content: string;
  strImageJSON: string;
  auxLib: integer;
begin
  auxLib:=0;

  content:='https://api.vagalume.com.br/search.php?art='+trim(vart.Text)+'&mus='+trim(vmus.Text)+'&apikey={key}';

  RESTClient1 := TRESTClient.Create(content);
  RESTRequest1 := TRESTRequest.Create(nil);

  // Envia Requisição à nova API para MultiItens
  RESTRequest1.Method := TRESTRequestMethod.rmGET;
  RESTRequest1.Resource := content;
  RESTRequest1.Client := RESTClient1;
  RESTRequest1.Timeout:= 600000;
  RESTRequest1.Execute;

  strImageJSON := RESTRequest1.Response.Content;

 // Atribuindo Resposta ao JSonObject
  if (LeftStr(Trim(strImageJSON),20)='{"type":"notfound"}') then
  begin
    ShowMessage('Artista não Encontrado!');
    exit;
  end;

  if (LeftStr(Trim(strImageJSON),20)='{"type":"song_notfou') then
  begin
    ShowMessage('Música não Encontrada!');
    exit;
  end;

  JSob := TJSONObject.ParseJSONValue(strImageJSON) as TJSONObject;

  Letra.Lines.Clear;

  // Criando Array com os valores do JSON
  jsonArray := jsob.GetValue<TJSONArray>('mus') as TJSONArray;
  jsonob := JSONArray.Items[0] as TJSONObject;

  content:=jsonob.GetValue('text').Value;
  Letra.Lines.Add(content);
end;

procedure TFLetra.FormShow(Sender: TObject);
begin
  vart.SetFocus;
end;

end.
