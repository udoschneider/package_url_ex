defmodule PackageUrl.URI do
  @moduledoc """
  Helper Module for JS-compatible URI en-/decoding.
  """

  # uriAlpha ::: one of
  #   a b c d e f g h i j k l m n o p q r s t u v w x y z
  #   A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  @uri_alpha 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  # DecimalDigit :: one of
  #   0 1 2 3 4 5 6 7 8 9
  @decimal_digit '0123456789'

  #   uriMark ::: one of
  #   - _ . ! ~ * ' ( )
  @uri_mark '-_.!~*\'()'

  # uriUnescaped :::
  #   uriAlpha
  #   DecimalDigit
  #   uriMark
  @uri_unescaped @uri_alpha ++ @decimal_digit ++ @uri_mark

  # uriReserved ::: one of
  #   ; / ? : @ & = + $ ,
  # @uriReserved ';/?:@&=+$,'

  @doc """
  Decodes an URI using the `uriReserved plus “#”` character set.
  """
  # Let reservedURISet be a String containing one instance of each character valid in uriReserved plus “#”.
  @spec decode_uri(binary) :: binary
  def decode_uri(string) when is_binary(string),
    do: URI.decode(string)

  @doc """
  Decodes an URI using the `reservedURIComponentSet` character set.
  """
  # Let reservedURIComponentSet be the empty String.
  @spec decode_uri_component(binary) :: binary
  def decode_uri_component(string) when is_binary(string),
    do: URI.decode(string)

  @doc """
  Encodes an URI using the `uriReserved and uriUnescaped plus “#”` character set.
  """
  # Let unescapedURISet be a String containing one instance of each character valid in uriReserved and uriUnescaped plus “#”.
  @spec encode_uri(binary) :: binary
  def encode_uri(string) when is_binary(string),
    # do: URI.encode(string, &(&1 in (@uriReserved ++ @uri_unescaped ++ '#')))
    do: URI.encode(string)

  @doc """
  Encodes an URI using the `uriUnescaped` character set.
  """
  # Let unescapedURIComponentSet be a String containing one instance of each character valid in uriUnescaped.
  @spec encode_uri_component(binary) :: binary
  def encode_uri_component(string) when is_binary(string),
    # do: URI.encode_www_form(string)
    do: URI.encode(string, &(&1 in @uri_unescaped))
end
