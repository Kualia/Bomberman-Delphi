object MainForm: TMainForm
  Left = 572
  Top = 291
  Caption = 'Form4'
  ClientHeight = 526
  ClientWidth = 799
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnKeyDown = ScreenKeyDown
  TextHeight = 15
  object Screen: TMemo
    Left = 104
    Top = 48
    Width = 569
    Height = 385
    Enabled = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Cascadia Mono'
    Font.Style = []
    Lines.Strings = (
      '##############################'
      '#  --  --- --- --- ---      ##'
      '#   #                #       #'
      '#  ##                --------#'
      '#   #                #   --  #'
      '#   ####   ###---#  ###  --- #')
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    OnKeyDown = ScreenKeyDown
  end
end