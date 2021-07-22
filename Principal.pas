unit Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, REST.Types, FMX.Layouts, FMX.ListBox, FMX.Edit,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.WebBrowser,
  FMX.ScrollBox, FMX.Memo, IdBaseComponent, IdComponent, IdTCPConnection, Registry,
  IdTCPClient, IdHTTP, System.JSON, FMX.ExtCtrls, FMX.Objects, StrUtils, WinInet,
  FMX.TabControl, FMX.Effects;

type
  TFLetra = class(TForm)
    Panel2: TPanel;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Traducao: TTabItem;
    Letra: TMemo;
    Trad: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    vart: TEdit;
    Label3: TLabel;
    vmus: TEdit;
    Buscar: TButton;
    BlurEffect1: TBlurEffect;
    ImageControl1: TImageControl;
    Memo1: TMemo;
    WebBrowser1: TWebBrowser;
    procedure BuscarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure BaixarImagem;
    function DownloadArquivo(const Origem, Destino: String): Boolean;
    procedure BaixarYouTube;
    function URLEncode(const ASrc: string): string;
    Procedure SetIEEmulation(VersaoIE : Integer);
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
  BaixarImagem;
  BaixarYouTube;

//  WebBrowser1.Visible:=false;

  TabControl1.TabIndex:=0;

  Traducao.Visible:=false;

  auxLib:=0;

  content:='https://api.vagalume.com.br/search.php?art='+trim(vart.Text)+'&mus='+trim(vmus.Text)+'&apikey={key}';

  RESTClient1 := TRESTClient.Create(content);
  RESTRequest1 := TRESTRequest.Create(nil);

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
  Trad.Lines.Clear;

  // Criando Array com os valores do JSON
  jsonArray := jsob.GetValue<TJSONArray>('mus') as TJSONArray;
  jsonob := JSONArray.Items[0] as TJSONObject;

  content:=jsonob.GetValue('text').Value;
  Letra.Lines.Add(content);

  /////////

//  strImageJSON:=jsonob.GetValue('translate').ToJSON;

//  JSob := TJSONObject.ParseJSONValue(strImageJSON) as TJSONObject;

  jsonArray := jsob.GetValue<TJSONArray>('mus') as TJSONArray;
  jsonob := JSONArray.Items[0] as TJSONObject;
  try
    strImageJSON:='{"translate":'+jsonob.GetValue('translate').ToJSON+'}';
  except
    Traducao.Visible:=false;
    exit;
  end;

  Traducao.Visible:=true;

  JSob := TJSONObject.ParseJSONValue(strImageJSON) as TJSONObject;

  // Criando Array com os valores do JSON
  jsonArray := jsob.GetValue<TJSONArray>('translate') as TJSONArray;
  jsonob := JSONArray.Items[0] as TJSONObject;

  content:=jsonob.GetValue('text').Value;

  Trad.Lines.Add(content);

//  BaixarImagem;
//  BaixarYouTube;
end;

procedure TFLetra.FormShow(Sender: TObject);
begin
  SetIEEmulation(11);

  vart.SetFocus;
end;

procedure TFLetra.BaixarImagem;
var
  link: string;
  destino: string;
  artista: string;
begin
  ImageControl1.LoadFromFile('C:\Users\DevDelphi\Desktop\Anderson D C\Estudos Delphi\Busca Letra Musica API\Fundo.jpg');

  artista:=StringReplace(trim(vart.Text), ' ', '-',
    [rfReplaceAll, rfIgnoreCase]);

  link:='https://www.vagalume.com.br/'+trim(artista)+'/images/'+trim(artista)+'.jpg';
  destino:='C:\Users\DevDelphi\Desktop\Anderson D C\Estudos Delphi\Busca Letra Musica API\Imagem.jpg';

  if DownloadArquivo(link, destino) then
    ImageControl1.LoadFromFile(destino);

end;

procedure TFLetra.BaixarYouTube;
var
  link: string;
  artista: string;
  nomemusica: string;
  Web: TIDHTTP;

  linkPlay: string;
  idMusica: string;
begin
  WebBrowser1.Visible:=false;

  artista:=StringReplace(trim(vart.Text), ' ', '+',
    [rfReplaceAll, rfIgnoreCase]);
  nomemusica:=StringReplace(trim(vmus.Text), ' ', '+',
    [rfReplaceAll, rfIgnoreCase]);

  link:='https://www.youtube.com/results?search_query='+artista+'+'+nomemusica;

  Web:=TIDHTTP.Create(nil);
  memo1.Lines.Text:=Web.Get(link);
  WEb.Free;

  idMusica:=copy(memo1.Lines.Text, pos('videoId',memo1.Lines.Text)+10,13);
  idMusica:=StringReplace(trim(idMusica), '"', '',[rfReplaceAll, rfIgnoreCase]);
  idMusica:=StringReplace(trim(idMusica), ',', '',[rfReplaceAll, rfIgnoreCase]);

  linkPlay:='https://www.youtube.com/embed/'+idMusica+'?autoplay=1';

  memo1.Lines.Clear;
  memo1.Lines.Text:='<iframe id="ytplayer" type="text/html" width="337" height="209"'+
                    'src="http://www.youtube.com/embed/'+idMusica+'?autoplay=1&origin=http://example.com"'+
                    'frameborder="0"/>';
  memo1.Lines.SaveToFile('C:\Users\DevDelphi\Desktop\Anderson D C\Estudos Delphi\Busca Letra Musica API\Video.html');

  WebBrowser1.Visible:=true;
  WebBrowser1.URL:=('C:\Users\DevDelphi\Desktop\Anderson D C\Estudos Delphi\Busca Letra Musica API\Video.html');
  WebBrowser1.Navigate;

end;

// versões IE: 7, 8, 9 10 e 11
Procedure TFLetra.SetIEEmulation(VersaoIE : Integer);
Var
   R : TRegistry;
   V : Integer;
Begin
   V := 11001;
   Case VersaoIE Of
      7 : V := 7000;
      8 : V := 8888;
      9 : V := 9999;
      10 : V := 10001;
      11 : V := 11001;
   End;
   // internet explorer 11 = 11000 ou 11001
   // internet explorer 10 = 10000 ou 10001
   // internet explorer 9 = 9000 ou 9999
   // internet explorer 8 = 8000 ou 8888
   // internet explorer 7 = 7000
   // https://msdn.microsoft.com/en-us/library/ee330730%28v=vs.85%29.aspx
   // resumidamente, esta função grava um valor no registro que força a emulação da versão do Internet Explorer para o programa indicado
   // só é preciso o nome do programa, não é necessário o path completo
   R := TRegistry.Create;
   Try
//      R.RootKey := 'HKEY_CURRENT_USER';
      R.OpenKey('SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\',False);
      // código para emular o internet explorer 11
      R.WriteInteger(ExtractFileName(ParamStr(0)),V);
   Finally
      R.CloseKey;
      R.Free;
   End;
End;

function TFLetra.DownloadArquivo(const Origem, Destino: String): Boolean;
const BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  f: File;
  sAppName: string;
begin
  Result   := False;
//  sAppName := ExtractFileName(Application.ExeName);
  hSession := InternetOpen(PChar(sAppName),
              INTERNET_OPEN_TYPE_PRECONFIG,
              nil, nil, 0);
  try
    hURL := InternetOpenURL(hSession,
            PChar(Origem),
            nil,0,0,0);
    try
      AssignFile(f, Destino);
      Rewrite(f,1);
      repeat
        InternetReadFile(hURL, @Buffer,
                     SizeOf(Buffer), BufferLen);
        BlockWrite(f, Buffer, BufferLen)
      until BufferLen = 0;

      CloseFile(f);
      Result:=True;
    finally
     InternetCloseHandle(hURL)
    end
  except
    result:=false;
  end;

  InternetCloseHandle(hSession);

end;

function TFLetra.URLEncode(const ASrc: string): string;
var
  i: Integer;
const
  UnsafeChars = ['*', '#', '%', '<', '>', ' ', '[', ']']; { do not localize }
begin
  Result := ''; { Do not Localize }
  for i := 1 to length(ASrc) do
  begin
    if (ASrc[i] in UnsafeChars) or (not(Ord(ASrc[i]) in [33 .. 128])) then
    begin { do not localize }
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2); { do not localize }
    end
    else
    begin
      Result := Result + ASrc[i];
    end;
  end;
end;

end.
