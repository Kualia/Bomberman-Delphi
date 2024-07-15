object MainForm: TMainForm
  Left = 409
  Top = 208
  Caption = 'Form4'
  ClientHeight = 584
  ClientWidth = 882
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnKeyDown = KeyDown
  TextHeight = 15
  object Screen: TMemo
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 882
    Height = 584
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvSpace
    EditMargins.Auto = True
    Enabled = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Cascadia Mono'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    OnKeyDown = KeyDown
    ExplicitWidth = 832
    ExplicitHeight = 545
  end
end
